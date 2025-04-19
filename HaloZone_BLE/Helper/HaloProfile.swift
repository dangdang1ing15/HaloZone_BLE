import Foundation

struct HaloProfile: Codable, Identifiable {
    let id: UUID
    let name: String
    let message: String
    let isAngel: Bool
    let userHash: String   // ✅ 추가

    var emoji: String { isAngel ? "😇" : "🤔" }

    init(name: String, message: String, isAngel: Bool, userHash: String) {
        self.id = UUID()
        self.name = name
        self.message = message
        self.isAngel = isAngel
        self.userHash = userHash
    }

    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.message = try container.decode(String.self, forKey: .message)
            self.isAngel = try container.decode(Bool.self, forKey: .isAngel)
            self.userHash = try container.decode(String.self, forKey: .userHash)
            self.id = UUID()
        }


    enum CodingKeys: String, CodingKey {
        case name, message, isAngel, userHash
    }
}
