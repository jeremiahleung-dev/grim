import Foundation

struct LifeItem: Identifiable, Codable {
    let id: UUID
    var text: String
    let createdAt: Date

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
    }
}
