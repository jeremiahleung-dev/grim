import Foundation

struct DayTask: Identifiable, Codable {
    let id: UUID
    var text: String

    init(text: String) {
        self.id = UUID()
        self.text = text
    }
}
