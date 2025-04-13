import SwiftUI

struct MyProfileView: View {
    @State private var isEditing = false
    @Namespace private var animation

    var body: some View {
        ZStack {
            // 메인 카드
            HStack(spacing: 0) {
                VStack {
                    Spacer(minLength: 24)
                    CircleView(state: false)
                        .environment(\.colorScheme, .light)
                        .padding(.leading, 24)
                    Spacer(minLength: 24)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Eilan")
                        .font(.title)
                        .fontWeight(.bold)

                    Text(#""지금은 꽤 한가로워요""#)
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
                    isEditing = true
                }
            }

            // 프로필 편집 Sheet
            if isEditing {
                EditProfileSheetView(isEditing: $isEditing, animation: animation)
                    .transition(.opacity)
            }
        }
    }
}
