import Foundation

struct MyProfile: Codable {
    var name: String
    var message: String
    var isAngel: Bool
    var userHash: String
    var lastmodified: String
}

// 경로 설정
func getProfileURL() -> URL {
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentDirectory.appendingPathComponent("MyProfile.json")
}

func saveProfile(_ profile: MyProfile) {
    do {
        let data = try JSONEncoder().encode(profile)
        try data.write(to: getProfileURL())
        print("✅ 프로필 저장 완료")
    } catch {
        print("❌ 저장 실패: \(error)")
    }
}

func loadProfile() -> MyProfile {
    let url = getProfileURL()
    guard let data = try? Data(contentsOf: url),
          let profile = try? JSONDecoder().decode(MyProfile.self, from: data) else {
        // 기본값 반환
        return MyProfile(name: "nil", message: "메시지를 입력하세요", isAngel: false, userHash: "0000", lastmodified: "")
    }
    return profile
}

func updateAngelStatus(_ isAngel: Bool) {
    var profile = loadProfile()
    profile.isAngel = isAngel
    profile.lastmodified = formattedNow()
    saveProfile(profile)
}

private func formattedNow() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter.string(from: Date())
}

