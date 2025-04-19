import Foundation

struct ServerProfile: Codable, Identifiable {
    var id: String { userHash }
    let userHash: String
    let nickname: String
    let isHaloEnabled: Bool
    let statusMessage: String
    let timestamp: String
}

class ProfileAPIService {
    static let shared = ProfileAPIService()

    private let baseURL = Secrets.haloAPIBaseURL
    private let apiKey = Secrets.haloAPIKey

    func fetchProfiles(for hashes: [String], completion: @escaping (Result<[ServerProfile], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/batch") else {
            return completion(.failure(APIError.invalidURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let payload = ["hashes": hashes]
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(APIError.noData))
            }

            do {
                let decoded = try JSONDecoder().decode([ServerProfile].self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    enum APIError: Error {
        case invalidURL, noData
    }
}
