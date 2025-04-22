import SwiftUI
import UIKit

struct NearbyHaloSheetOverlayView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var peripheralManager: BLEPeripheralManager
    @ObservedObject var centralManager: BLECentralManager
    @Binding var isPresented: Bool

    @GestureState private var dragOffset: CGFloat = 0
    @State private var animatedOffset: CGFloat = 0
    @State private var animatedOpacity: Double = 1
    @State private var isAutoDismissing = false
    @State private var shouldHideContent = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

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
            .offset(y: isAutoDismissing ? animatedOffset : dragOffset)
            .opacity(isAutoDismissing ? animatedOpacity : 1.0)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height > 0 {
                            state = value.translation.height
                        } else {
                            state = 0 // 위로 끌면 무시
                        }
                    }
                    .onEnded { value in
                        let screenHeight = UIScreen.main.bounds.height
                        let threshold = screenHeight * 0.2

                        if value.translation.height > threshold {
                            animatedOffset = value.translation.height // 현재 위치부터 계속 내려가기
                            startAutoDismiss()
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

    func startAutoDismiss() {
        let screenHeight = UIScreen.main.bounds.height
        let targetOffset: CGFloat = screenHeight * 0.6

        isAutoDismissing = true

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }

        // ✅ 빠른 fade-out
        withAnimation(.easeOut(duration: 0.3)) {
            animatedOffset = targetOffset
            animatedOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animatedOffset = 0
            animatedOpacity = 1
            isAutoDismissing = false

            DispatchQueue.main.async {
                isPresented = false
            }
        }
    }
}
