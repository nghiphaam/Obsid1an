import SwiftUI

struct RustResearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedFamily = "All"
    @State private var selectedMode: RustMode?

    private var filteredModes: [RustMode] {
        RustCatalog.modes.filter { mode in
            let familyMatches = selectedFamily == "All" || mode.family == selectedFamily
            let searchMatches = searchText.isEmpty
                || mode.title.localizedCaseInsensitiveContains(searchText)
                || mode.family.localizedCaseInsensitiveContains(searchText)
                || String(mode.id).contains(searchText)
                || (mode.versionTag?.localizedCaseInsensitiveContains(searchText) ?? false)
            return familyMatches && searchMatches
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.title2.weight(.semibold))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("RUST Research").font(.headline)
                                Text("Read-only mode catalogue").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(RustCatalog.modes.count)")
                                .font(.title2.monospacedDigit().weight(.bold))
                        }
                        Text("RUST UI claims: WRITE · V562 | PANIC · V575")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text("The source UI advertises 565+ primitives for iOS 26–27. This local catalogue contains labels recovered from the supplied executable; these are not verified working exploits.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .textCase(nil)
                }

                Section("Filter") {
                    Picker("Family", selection: $selectedFamily) {
                        Text("All families").tag("All")
                        ForEach(RustCatalog.families, id: \.self) { family in
                            Text(family).tag(family)
                        }
                    }
                }

                Section("Modes · \(filteredModes.count)") {
                    ForEach(filteredModes) { mode in
                        Button {
                            selectedMode = mode
                        } label: {
                            HStack(spacing: 12) {
                                Text(String(format: "%03d", mode.id))
                                    .font(.caption.monospacedDigit().weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 36, alignment: .leading)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(mode.title)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)
                                    Text(mode.family)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 8)
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section {
                    Label("Metadata only — no exploit execution is connected.", systemImage: "lock.shield")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("RUST Research")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search name, family, index, or version")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(item: $selectedMode) { mode in
            RustModeDetailView(mode: mode)
        }
    }
}

private struct RustModeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let mode: RustMode

    var body: some View {
        NavigationStack {
            List {
                Section("Entry") {
                    LabeledContent("Catalogue index", value: String(mode.id))
                    LabeledContent("Family", value: mode.family)
                    if let versionTag = mode.versionTag {
                        LabeledContent("Version tag", value: versionTag)
                    }
                    LabeledContent("Name", value: mode.title)
                }
                Section("Evidence") {
                    Label("Label recovered from executable strings", systemImage: "checkmark.circle")
                    Text("A string embedded in a binary confirms only that the label exists. It does not establish that the corresponding primitive executes, is reliable, supports this device or OS build, or completes a jailbreak. Some source labels may be partial or truncated.")
                    Text("The displayed index is assigned by this catalogue and is not an original RUST mode identifier.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Integration") {
                    Label("Read-only metadata", systemImage: "info.circle")
                    Text("No runner, trigger, kernel primitive, panic operation, or privileged action is exposed here.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Entry #\(mode.id)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
