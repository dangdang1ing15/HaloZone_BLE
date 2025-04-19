import Foundation

class NearbyHaloListViewModel: ObservableObject {
    @Published var profiles: [ServerProfile] = []

    func loadProfiles(from hashes: [String]) {
        ProfileAPIService.shared.fetchProfiles(for: hashes) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loaded):
                    self.profiles = loaded
                case .failure(let error):
                    print("❌ 프로필 로딩 실패: \(error)")
                    self.profiles = []
                }
            }
        }
    }
}
