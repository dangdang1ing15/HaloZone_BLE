import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profile: MyProfile = loadProfile()

    func updateName(_ name: String) {
        profile.name = name
        profile.lastmodified = formattedNow()
        saveProfile(profile)
    }

    func updateMessage(_ message: String) {
        var updated = profile
        updated.message = message
        updated.lastmodified = formattedNow()
        profile = updated
        saveProfile(profile)
    }


    func updateIsAngel(_ isAngel: Bool) {
        var newProfile = profile
        newProfile.isAngel = isAngel
        newProfile.lastmodified = formattedNow()
        profile = newProfile
        saveProfile(newProfile)

        // ✅ 서버 상태 동기화 추가
        syncHaloStatusToServer(isHaloEnabled: isAngel)
    }

    private func syncHaloStatusToServer(isHaloEnabled: Bool) {
        let profile = self.profile

        let body: [String: Any] = [
            "nickname": profile.name,
            "statusMessage": profile.message,
            "isHaloEnabled": isHaloEnabled,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        guard let url = URL(string: "\(Secrets.haloAPIBaseURL)/user/\(profile.userHash)"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("❌ URL 또는 JSON 직렬화 실패 (Halo 상태 업로드)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.haloAPIKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 isHaloEnabled 서버 동기화 완료 (code: \(httpResponse.statusCode))")
            } else if let error = error {
                print("❌ HALO 상태 동기화 실패: \(error)")
            }
        }.resume()
    }


    func reload() {
        profile = loadProfile()
    }

    private func formattedNow() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
