import Foundation
import Combine

class HaloTimerManager: ObservableObject {
    @Published var elapsedSeconds: Int = UserDefaults.standard.integer(forKey: "elapsedSeconds")
    private var timer: Timer?
    
    // 타이머 시작
    func start() {
        stop() // 중복 방지
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedSeconds += 1
        }
    }

    // 타이머 중지 + 저장
    func stop() {
        timer?.invalidate()
        timer = nil
        UserDefaults.standard.set(elapsedSeconds, forKey: "elapsedSeconds")
    }

    // 초기화
    func reset() {
        elapsedSeconds = 0
        UserDefaults.standard.set(0, forKey: "elapsedSeconds")
    }

    // 수동 로딩 (옵션)
    func load() {
        elapsedSeconds = UserDefaults.standard.integer(forKey: "elapsedSeconds")
    }

    // 시간 포맷 → "HH:mm:ss"
    func formattedTime() -> String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
