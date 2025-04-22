import SwiftUI
import Lottie
 
struct LottieView: UIViewRepresentable {
    
    let fileName: String
    let loopMode : LottieLoopMode
   
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let lottieAnimationView = LottieAnimationView(name: fileName)
        lottieAnimationView.contentMode = .scaleAspectFit
        lottieAnimationView.loopMode = loopMode
        lottieAnimationView.play()
        lottieAnimationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lottieAnimationView)
        NSLayoutConstraint.activate([
            lottieAnimationView.widthAnchor.constraint(equalTo:view.widthAnchor),
            lottieAnimationView.heightAnchor.constraint(equalTo:view.heightAnchor)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
