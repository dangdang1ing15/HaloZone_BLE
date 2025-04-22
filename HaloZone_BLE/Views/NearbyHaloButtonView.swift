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
    @State private var isPressed: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                VStack {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(Color.white.opacity(0.5))
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
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isPressed = true
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                isPressed = false
                            }

                            if value.translation.height < -50 {
                                withAnimation(.spring()) {
                                    showHalos = true
                                }
                            }
                        }
                )
            }

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
                .animation(.spring(), value: showHalos)
            }
        }
    }
}
