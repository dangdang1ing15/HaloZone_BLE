import Foundation

enum Secrets {
    static let shared: NSDictionary = {
        guard let url = Bundle.main.url(forResource: "api", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url) else {
            fatalError("❌ Secrets.plist 로딩 실패")
        }
        return dict
    }()

    static var haloAPIBaseURL: String {
        guard let value = shared["HaloAPIBaseURL"] as? String else {
            fatalError("❌ HaloAPIBaseURL 없음")
        }
        return value
    }

    static var haloAPIKey: String {
        guard let value = shared["HaloAPIKey"] as? String else {
            fatalError("❌ HaloAPIKey 없음")
        }
        return value
    }
}
