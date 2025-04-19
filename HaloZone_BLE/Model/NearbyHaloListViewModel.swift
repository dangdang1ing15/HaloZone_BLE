import Foundation
import Combine

class NearbyHaloListViewModel: ObservableObject {
    @Published var profiles: [HaloProfile] = []

    private var timer: Timer?
    private let refreshInterval: TimeInterval = 15 * 60 // 15분

    init() {
        load()
        startAutoRefresh()
    }

    func load() {
        profiles = loadNearbyProfiles()
        print("🔁 Nearby 프로필 로드 완료 (\(profiles.count)명)")
    }

    func startAutoRefresh() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            print("⏰ 자동 새로고침 실행")
            self?.load()
        }
    }
    
    func syncWithServer() {
            syncNearbyProfilesFromServer {
                DispatchQueue.main.async {
                    self.load()
                }
            }
        }
    
    deinit {
        timer?.invalidate()
    }
}
