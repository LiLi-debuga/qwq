import Foundation

struct Todo: Identifiable, Codable {
    var id: Int
    var content: String
    var done: Bool
    var hour: Int   // -1 = no reminder
    var minute: Int
    var repeatDaily: Bool
}
