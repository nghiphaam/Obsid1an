import Foundation

/// Read-only catalogue metadata recovered from the supplied RUSTJailbreak executable.
struct RustMode: Identifiable, Hashable {
    let id: Int
    let family: String
    let title: String

    var versionTag: String? {
        guard let range = title.range(of: #"\\bV\\d+\\b"#, options: .regularExpression) else {
            return nil
        }
        return String(title[range])
    }
}
