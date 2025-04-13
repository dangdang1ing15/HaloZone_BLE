import Foundation

struct HaloProfile: Codable, Identifiable {
    // id는 객체 생성 시 유니크하게 생성 (옵션: JSON에 id가 있으면 그걸 사용)
    let id = UUID()
    let name: String
    let message: String
    let isAngel: Bool
    
    var emoji: String {
        isAngel ? "😇" : "🤔"
    }
}

func loadHaloProfiles() -> [HaloProfile] {
    // 번들에서 JSON 파일의 URL을 찾음
    guard let url = Bundle.main.url(forResource: "HaloProfiles", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let profiles = try? JSONDecoder().decode([HaloProfile].self, from: data) else {
        print("JSON 로딩 실패")
        return []
    }
    return profiles
}
