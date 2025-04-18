import SwiftUI

struct NearbyHaloButtonView: View {
    @State private var showHalos = false
    @ObservedObject var profileVM: ProfileViewModel
    @Binding var isHaloEnabled: Bool
    @Binding var isEditing: Bool
    @ObservedObject var peripheralManager: BLEPeripheralManager
    @ObservedObject var centralManager: BLECentralManager
    @StateObject private var viewModel = NearbyHaloListViewModel()
    @GestureState private var dragOffset: CGFloat = 0

    var sheetScale: CGFloat {
        let drag = min(dragOffset, 150)
        return max(0.94, 1.0 - drag / 1000) // 최대 6% 축소
    }

    var body: some View {
        VStack {
            if profileVM.profile.isAngel && isHaloEnabled {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isEditing = true
                    }
                } label: {
                    VStack(spacing: 4) {
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(Color(.gray).opacity(0.5))
                            .padding(.bottom, 5)
                        
                        Text("\"\(profileVM.profile.message)\"")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))

                        Text("상태메시지 작성시각 : \(formatted(profileVM.profile.lastmodified))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(height: 75)
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
                    .preferredColorScheme(.dark)
                    .cornerRadius(20)
                    .padding()
                }
            } else {
                VStack {
                    VStack {
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(Color(red: 0.40, green: 0.40, blue: 0.40, opacity: 0.5))
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
                    .onTapGesture {
                        showHalos.toggle()
                    }
                }
                .sheet(isPresented: $showHalos) {
                    NearbyHaloSheetView(
                        profileVM: profileVM,
                        peripheralManager: peripheralManager,
                        centralManager: centralManager,
                        scale: sheetScale // ✅ 전달
                    )
                    .presentationDetents([.fraction(0.9)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(30)
                    .presentationContentInteraction(.resizes)
                    .presentationBackground(.thinMaterial)
                    .preferredColorScheme(.dark)
                    .safeAreaPadding()
                }
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.height
                        }
                )
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
