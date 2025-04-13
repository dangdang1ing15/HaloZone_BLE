import SwiftUI

struct EditProfileSheetView: View {
    @Binding var isEditing: Bool
    var animation: Namespace.ID

    var body: some View {
        ZStack {
            // 블러 배경
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .blur(radius: 10)
                .onTapGesture {
                    withAnimation {
                        isEditing = false
                    }
                }

            // 확장된 카드
            VStack(spacing: 16) {
                HStack {
                    Button("취소") {
                        withAnimation {
                            isEditing = false
                        }
                    }

                    Spacer()

                    Button("수정하기") {
                        // 수정 로직
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)

                VStack(spacing: 8) {
                    CircleView(state: false)
                        .environment(\.colorScheme, .light)
                        .frame(width: 100, height: 100)

                    Text("Eilan")
                        .font(.title)
                        .fontWeight(.bold)

                    Divider()
                        .frame(width: 160)

                    Text(#""지금은 꽤 한가로워요""#)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .frame(width: 300, height: 340)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .matchedGeometryEffect(id: "profileCard", in: animation)
            .padding()
        }
    }
}
