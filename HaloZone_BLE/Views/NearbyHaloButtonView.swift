import SwiftUI

struct NearbyHaloButtonView: View {
    @State private var showHalos = false
    @ObservedObject var profileVM: ProfileViewModel
    @Binding var isHaloEnabled: Bool
    @Binding var isEditing: Bool
    @ObservedObject var peripheralManager: BLEPeripheralManager
    @ObservedObject var centralManager: BLECentralManager
    @StateObject private var viewModel = NearbyHaloListViewModel()

    @GestureState private var dragOffset: CGSize = .zero
    @State private var isPressed = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                // ✅ 조건 분기
                if profileVM.profile.isAngel && isHaloEnabled {
                    VStack(spacing: 4) {
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.bottom, 5)

                        Text("\"\(profileVM.profile.message)\"")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))

                        Text("상태메시지 작성시각 : \(formatted(profileVM.profile.lastmodified))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(height: isEditing ? 120 : 75) // ✅ 부풀기
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
                    .preferredColorScheme(.dark)
                    .cornerRadius(20)
                    .padding()
                    .scaleEffect(isPressed ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 0.35), value: isEditing)
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onChanged { _ in
                                withAnimation(.spring()) { isPressed = true }
                            }
                            .onEnded { value in
                                withAnimation(.spring()) { isPressed = false }

                                if value.translation.height < -50 {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        isEditing = true
                                    }
                                }
                            }
                    )
                } else {
                    VStack(spacing: 4) {
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.bottom, 5)

                        Text("내 주변 천사들")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("10미터 이내 \(viewModel.profiles.count)명")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(height: 75)
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
                    .preferredColorScheme(.dark)
                    .cornerRadius(20)
                    .padding()
                    .scaleEffect(isPressed ? 1.05 : 1.0)
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onChanged { _ in
                                withAnimation(.spring()) { isPressed = true }
                            }
                            .onEnded { value in
                                withAnimation(.spring()) { isPressed = false }

                                if value.translation.height < -50 {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    withAnimation {
                                        showHalos = true
                                    }
                                }
                            }
                    )
                }
            }

            // ✅ 주변 목록 뷰
            if showHalos {
                NearbyHaloSheetOverlayView(
                    profileVM: profileVM,
                    peripheralManager: peripheralManager,
                    centralManager: centralManager,
                    isPresented: $showHalos
                )
                .ignoresSafeArea()
                .background(
                    Color.black.opacity(0.001)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation { showHalos = false }
                        }
                )
                .transition(.move(edge: .bottom))
            }
        }
    }

    private func formatted(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = formatter.date(from: dateString) else { return "" }

        let display = DateFormatter()
        display.dateFormat = "HH:mm"
        return display.string(from: date)
    }
}
