import SwiftUI

struct MyProfileView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @State private var profile: MyProfile = loadProfile()
    @State private var isEditing = false
    @Namespace private var animation
    @State private var editViewKey = UUID()

    var body: some View {
        ZStack {

            HStack(spacing: 0) {
                VStack {
                    Spacer(minLength: 24)
                    CircleView(state: false)
                        .environment(\.colorScheme, .light)
                        .padding(.leading, 24)
                    Spacer(minLength: 24)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(profileVM.profile.name)
                            .font(.title)
                            .fontWeight(.bold)

                    Text("\"\(profileVM.profile.message)\"")
                            .font(.subheadline)
                    }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: 148)
            .background(.thinMaterial)
            .cornerRadius(20)
            .matchedGeometryEffect(id: "profileCard", in: animation)
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    editViewKey = UUID()
                    isEditing = true
                }
            }

            // 🟣 수정 시트 (중앙에 떠 있는 카드)
            if isEditing {
                EditProfileSheetView(profileVM: profileVM, isEditing: $isEditing, animation: animation)
                    .id(editViewKey)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }
}
