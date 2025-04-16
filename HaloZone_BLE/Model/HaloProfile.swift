import Foundation

struct HaloProfile: Codable, Identifiable {
    let id = UUID()
    let name: String
    let message: String
    let isAngel: Bool
    
    var emoji: String {
        isAngel ? "😇" : "🤔"
    }
}

func loadHaloProfiles() -> [HaloProfile] {
    guard let url = Bundle.main.url(forResource: "HaloProfiles", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let profiles = try? JSONDecoder().decode([HaloProfile].self, from: data) else {
        print("JSON 로딩 실패")
        return []
    }
    return profiles
}
