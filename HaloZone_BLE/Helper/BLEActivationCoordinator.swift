import Foundation
import Combine

class BLEActivationCoordinator: ObservableObject {
    @Published var shouldStartBLE: Bool = false

    static let shared = BLEActivationCoordinator()

    private init() {}

    func activate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.shouldStartBLE = true
        }
    }

    func reset() {
        shouldStartBLE = false
    }
}
