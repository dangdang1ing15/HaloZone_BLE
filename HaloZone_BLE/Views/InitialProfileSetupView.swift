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
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
           ZStack {
               Color(red: 248/255, green: 192/255, blue: 60/255) // 노란 배경
                   .ignoresSafeArea()

               VStack(spacing: 24) {
                   Spacer().frame(height: 60)

                   Text("HaloZone")
                       .font(.title)
                       .fontWeight(.bold)
                       .foregroundColor(.white)
                   GeometryReader { geometry in
                       VStack {
                           Spacer()
                           LottieView(
                            fileName: "HaloRing_init",
                            loopMode: .loop
                           )
                           .frame(
                            width: geometry.size.width * 1.3,
                            height: geometry.size.width * 1.3
                           )
                           .offset(
                            x: geometry.size.width * -0.17,
                            y: geometry.size.height * 0
                           )
                           .clipped()
                       }
                       .frame(height: 300)
                   }

                   UnderlinedTextField(
                       text: $name,
                       placeholder: "이름을 입력해주세요",
                       isFocused: $isTextFieldFocused
                   )
                   

                   if isSubmitting {
                       ProgressView("등록 중...")
                           .progressViewStyle(CircularProgressViewStyle(tint: .white))
                   } else {
                       Button(action: {
                           isSubmitting = true
                           generateUniqueUserHash { hash in
                               userHash = hash
                               registerProfile()
                           }
                       }) {
                           Text("확인")
                               .fontWeight(.bold)
                               .foregroundColor(.white)
                               .padding(.vertical, 12)
                               .frame(maxWidth: .infinity)
                               .background(Color(red: 144/255, green: 117/255, blue: 34/255)) // 약간 어두운 골드
                               .cornerRadius(20)
                               .padding(.horizontal, 80)
                       }
                   }
                   Spacer()
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

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.haloAPIKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 응답 코드: \(httpResponse.statusCode)")
                if (200...299).contains(httpResponse.statusCode) {
                    saveProfile(MyProfile(name: name, message: fixedMessage, isAngel: false, userHash: userHash, lastmodified: formattedNow()))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        BLEActivationCoordinator.shared.activate()
                        isProfileInitialized = true
                    }
                } else {
                    print("❌ 프로필 등록 실패, 상태 코드: \(httpResponse.statusCode)")
                }
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

struct UnderlinedTextField: View {
    @Binding var text: String
    var placeholder: String
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        VStack(spacing: 4) {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.8)))
                .focused($isFocused)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.vertical, 10)
                .background(Color.clear)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16),
                    alignment: .bottom
                )
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    @AppStorage("isProfileInitialized") var isProfileInitialized = false
    
    InitialProfileSetupView(isProfileInitialized: $isProfileInitialized)
}
