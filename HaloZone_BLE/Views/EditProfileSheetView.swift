import SwiftUI

struct EditProfileSheetView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @Binding var isEditing: Bool
    var animation: Namespace.ID

    @State private var name: String = ""
    @State private var message: String = ""
    @FocusState private var isMessageFocused: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                HStack {
                    Button("취소") {
                        withAnimation(.easeOut(duration: 0.15)) {
                            isEditing = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() ) {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }



                    Spacer()

                    Button("수정하기") {
                        profileVM.updateName(name)
                        profileVM.updateMessage(message)

                        // ✅ 로컬 프로필 업데이트 및 저장
                        var updatedProfile = loadProfile()
                        updatedProfile.name = name
                        updatedProfile.message = message
                        updatedProfile.lastmodified = formattedNow()
                        saveProfile(updatedProfile)

                        // ✅ 서버에 동기화
                        uploadProfileToServer(updatedProfile)

                        withAnimation(.easeOut(duration: 0.15)) {
                            isEditing = false
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)

                VStack(spacing: 8) {
                    CircleView(state: profileVM.profile.isAngel)
                        .environment(\.colorScheme, .light)
                        .frame(width: 100, height: 100)

                    VStack(spacing: 4) {
                        TextField("이름", text: $name)
                            .multilineTextAlignment(.center)
                            .font(.title2)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 32)
                    }

                    VStack(spacing: 4) {
                        TextField("상태 메시지", text: $message)
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .focused($isMessageFocused)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 8)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 32)
                    }
                }

                Spacer()
            }
            .background(.thinMaterial)
            .cornerRadius(20)
            .interactiveDismissDisabled(isMessageFocused)
            .onAppear {
                let profile = loadProfile()
                name = profile.name
                message = profile.message

                DispatchQueue.main.async {
                    isMessageFocused = true
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
        }
    }

    private func formattedNow() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    func dismissKeyboard(completion: @escaping () -> Void) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            completion()
        }
    }
    
    private func uploadProfileToServer(_ profile: MyProfile) {
        let body: [String: Any] = [
            "nickname": profile.name,
            "statusMessage": profile.message,
            "isHaloEnabled": profile.isAngel,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        guard let url = URL(string: "\(Secrets.haloAPIBaseURL)/user/\(profile.userHash)"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("❌ URL 또는 JSON 직렬화 실패")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.haloAPIKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 프로필 수정 완료: \(httpResponse.statusCode)")
            } else if let error = error {
                print("❌ 수정 실패: \(error)")
            }
        }.resume()
    }
}
