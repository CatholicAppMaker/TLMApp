import Foundation

struct SourceReference: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let note: String
    let url: String?
    let category: String?
    let rights: String?
    let attribution: String?
    let coverageNote: String?
}

struct QuickGuidance: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let body: String
    let sourceID: String?
}

struct CoverageWindow: Codable, Hashable, Sendable {
    let title: String
    let startDate: String
    let endDate: String
    let description: String
}
