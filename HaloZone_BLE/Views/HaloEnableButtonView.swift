import SwiftUI

struct HaloEnableButtonView: View {
    @Binding var isHaloEnabled: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()

                Button(action: {
                    isHaloEnabled.toggle()
                }) {
                    LottieView(
                        fileName: isHaloEnabled ? "HaloRing_Yellow" : "HaloRing_White",
                        loopMode: .loop
                    )
                    .frame(
                        width: geometry.size.width * 1.3,
                        height: geometry.size.width * 1.3
                    )
                    .offset(
                            x: geometry.size.width * -0.03,
                            y: geometry.size.height * -0.1
                    )
                    .clipped()
                }

                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(height: 300)
    }
}


