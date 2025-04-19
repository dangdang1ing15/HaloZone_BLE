import Foundation

struct ServerProfile: Codable, Identifiable {
    var id: String { userHash }

    let userHash: String
    let nickname: String
    let isHaloEnabled: Bool
    let statusMessage: String
    let timestamp: String

    var toHaloProfile: HaloProfile {
        HaloProfile(
            name: nickname,
            message: statusMessage,
            isAngel: isHaloEnabled,
            userHash: userHash
        )
    }
}

func getNearbyProfileURL() -> URL {
    let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return doc.appendingPathComponent("NearbyHaloProfiles.json")
}

func saveNearbyProfilesToLocal(_ newProfiles: [ServerProfile]) {
    let url = getNearbyProfileURL()

    // ✅ 기존 로컬 JSON에서 HaloProfile 목록 불러오기
    let existing = loadNearbyProfiles()
    let existingHashes = Set(existing.map { $0.userHash }) // 중복 제거 기준

    // ✅ 여기서 변환!
    let haloProfiles = newProfiles.map { $0.toHaloProfile }
        .filter { !existingHashes.contains($0.userHash) } // 중복된 userHash 제거

    let merged = existing + haloProfiles

    // ✅ 저장
    do {
        let data = try JSONEncoder().encode(merged)
        try data.write(to: url)
        print("✅ Nearby 프로필 누적 저장 완료 (\(merged.count)명)")
    } catch {
        print("❌ 프로필 저장 실패: \(error)")
    }
}

func loadNearbyProfiles() -> [HaloProfile] {
    let url = getNearbyProfileURL()

    guard FileManager.default.fileExists(atPath: url.path) else {
        print("📁 초기 상태: NearbyHaloProfiles.json 없음")
        return []
    }

    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([HaloProfile].self, from: data)
        print("📄 디코딩된 프로필 수: \(decoded.count)")
        printNearbyProfileJSON() // ✅ 여기!
        return decoded
    } catch {
        print("❌ 디코딩 오류: \(error)")
        printNearbyProfileJSON() // ✅ 실패 시 원본도 출력
        return []
    }
}

func printNearbyProfileJSON() {
    let url = getNearbyProfileURL()
    do {
        let data = try Data(contentsOf: url)
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📄 저장된 NearbyHaloProfiles.json 내용:\n\(jsonString)")
        } else {
            print("⚠️ JSON 인코딩 실패 (UTF-8 아님?)")
        }
    } catch {
        print("❌ JSON 읽기 실패: \(error)")
    }
}

func syncNearbyProfilesFromServer(completion: @escaping () -> Void = {}) {
    let local = loadNearbyProfiles()
    let hashes = local.map { $0.userHash }

    guard !hashes.isEmpty else {
        print("⚠️ 동기화할 프로필이 없음")
        return completion()
    }

    ProfileAPIService.shared.fetchProfiles(for: hashes) { result in
        switch result {
        case .success(let serverProfiles):
            // ServerProfile → HaloProfile 변환
            let haloProfiles = serverProfiles.map { $0.toHaloProfile }

            do {
                let data = try JSONEncoder().encode(haloProfiles)
                try data.write(to: getNearbyProfileURL())
                print("✅ Nearby 프로필 최신 서버값으로 동기화 완료")
            } catch {
                print("❌ 동기화 저장 실패: \(error)")
            }
        case .failure(let error):
            print("❌ 서버 동기화 실패: \(error)")
        }
        completion()
    }
}
