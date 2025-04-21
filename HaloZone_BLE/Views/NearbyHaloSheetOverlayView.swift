import SwiftUI

struct NearbyHaloSheetOverlayView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var peripheralManager: BLEPeripheralManager
    @ObservedObject var centralManager: BLECentralManager
    @Binding var isPresented: Bool

    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer() // 하단 고정용

            VStack(spacing: 0) {
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top, 8)

                NearbyHaloSheetView(
                    profileVM: profileVM,
                    peripheralManager: peripheralManager,
                    centralManager: centralManager
                )
                .padding(.horizontal)
            }
            .background(.ultraThinMaterial)
            .cornerRadius(30)
            .scaleEffect(sheetScale)
            .offset(y: dragOffset > 0 ? dragOffset : 0)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.height
                    }
                    .onEnded { value in
                        if value.translation.height > 100 {
                            withAnimation { isPresented = false }
                        }
                    }
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: dragOffset)
        }
        .ignoresSafeArea()
    }

    var sheetScale: CGFloat {
        let drag = min(dragOffset, 150)
        return max(0.94, 1.0 - drag / 1000)
    }
}

