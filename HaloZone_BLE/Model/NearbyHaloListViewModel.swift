import Foundation
import Combine

class NearbyHaloListViewModel: ObservableObject {
    @Published var profiles: [HaloProfile] = []

    private var timer: Timer?
    private let refreshInterval: TimeInterval = 15 * 60 // 15분

    private var lastResetDate: String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private var lastResetKey = "NearbyResetDate"

    init() {
        load()
        startAutoRefresh()
        autoResetIfNeeded()
    }

    func autoResetIfNeeded() {
        let savedDate = UserDefaults.standard.string(forKey: lastResetKey)
        if savedDate != lastResetDate {
            print("🧹 하루 1회 Nearby 리스트 초기화")
            profiles = []
            UserDefaults.standard.set(lastResetDate, forKey: lastResetKey)
        }
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
