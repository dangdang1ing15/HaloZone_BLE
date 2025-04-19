//
//  InitialProfileSetupView.swift
//  HaloZone_BLE
//
//  Created by 성현 on 4/19/25.
//

import SwiftUI

struct InitialProfileSetupView: View {
    @Binding var isProfileInitialized: Bool
    @State private var name = ""
    @State private var userHash: String = ""
    @State private var isSubmitting = false

    var body: some View {
        VStack(spacing: 16) {
            Text("프로필 설정")
                .font(.title)
                .padding(.top, 40)

            TextField("닉네임", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            if isSubmitting {
                ProgressView("등록 중...")
            } else {
                Button("프로필 등록") {
                    isSubmitting = true
                    generateUniqueUserHash { hash in
                        userHash = hash
                        registerProfile()
                    }
                }
                .padding()
            }
        }
    }

    func registerProfile() {
        let fixedMessage = "초기 상태메시지입니다."

        let profile: [String: Any] = [
            "userHash": userHash,
            "nickname": name,
            "isHaloEnabled": false,
            "statusMessage": fixedMessage,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        guard let url = URL(string: "\(Secrets.haloAPIBaseURL)/user"),
              let body = try? JSONSerialization.data(withJSONObject: profile) else {
            print("❌ URL 또는 JSON 직렬화 실패")
            return
        }

        var request = URLRequest(url: url) // 🔧 여기서 try? 제거
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.haloAPIKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 응답 코드: \(httpResponse.statusCode)")
                if (200...299).contains(httpResponse.statusCode) {
                    saveProfile(MyProfile(name: name, message: fixedMessage, isAngel: false, lastmodified: formattedNow()))
                    DispatchQueue.main.async {
                        isProfileInitialized = true
                    }
                } else {
                    print("❌ 프로필 등록 실패, 상태 코드: \(httpResponse.statusCode)")
                }
            } else {
                print("❌ 응답 파싱 실패")
            }
        }.resume()
    }

    private func formattedNow() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    func generateRandomUserHash() -> String {
        let uuid = UUID().uuidString
        let hash = uuid.hashValue
        return String(format: "%04X", abs(hash) % 0xFFFF)
    }
    
    func checkHashExists(_ hash: String, completion: @escaping (Bool) -> Void) {
        let baseURL = Secrets.haloAPIBaseURL
        let apiKey = Secrets.haloAPIKey
        guard let url = URL(string: "\(baseURL)/user/\(hash)") else {
            return completion(true) // 실패 시 중복된 걸로 간주하고 재시도 유도
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(true)
            }
        }.resume()
    }
    
    func generateUniqueUserHash(completion: @escaping (String) -> Void) {
        func tryGenerate() {
            let hash = generateRandomUserHash()
            checkHashExists(hash) { exists in
                if exists {
                    print("⚠️ 해시 중복: \(hash), 재시도")
                    tryGenerate()
                } else {
                    print("✅ 고유 해시 확보: \(hash)")
                    completion(hash)
                }
            }
        }
        tryGenerate()
    }
}
