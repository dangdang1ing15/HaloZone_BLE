import SwiftUI

struct EditProfileCardView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @Binding var isEditing: Bool

    @State private var name: String = ""
    @State private var message: String = ""
    @FocusState private var isMessageFocused: Bool
    
    func dismissWithAnimation() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                isEditing = false
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("취소") {
                    dismissWithAnimation()
                }

                Spacer()

                Button("수정하기") {
                    profileVM.updateName(name)
                    profileVM.updateMessage(message)
                    dismissWithAnimation()
                }
            }
            .padding(.horizontal)

            CircleView(state: profileVM.profile.isAngel)
                .frame(width: 80, height: 80)

            TextField("이름", text: $name)
                .multilineTextAlignment(.center)
                .font(.title3)
                .focused($isMessageFocused)

            TextField("상태메시지", text: $message)
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .focused($isMessageFocused)

        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .frame(height: 280)
        .onAppear {
            name = profileVM.profile.name
            message = profileVM.profile.message
            DispatchQueue.main.async {
                isMessageFocused = true
            }
        }
    }
}
