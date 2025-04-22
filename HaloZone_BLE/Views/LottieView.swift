import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let fileName: String
    let loopMode: LottieLoopMode

    class Coordinator {
        var animationView: LottieAnimationView?
        var currentFileName: String?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: fileName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.play()

        context.coordinator.animationView = animationView
        context.coordinator.currentFileName = fileName

        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = context.coordinator.animationView else { return }

        // fileName이 바뀐 경우에만 애니메이션 갱신
        if context.coordinator.currentFileName != fileName {
            animationView.stop()
            animationView.animation = LottieAnimation.named(fileName)
            animationView.loopMode = loopMode
            animationView.play()
            context.coordinator.currentFileName = fileName
        }
    }
}
