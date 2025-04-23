import Foundation
import CoreBluetooth
import UserNotifications
import UIKit

class BLECentralManager: NSObject, ObservableObject {
    private var recentPeerTimestamps: [String: Date] = [:]
    private(set) var centralManager: CBCentralManager!
    private let targetServiceUUID = CBUUID(string: "1234")
    private let localDeviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    private var receivedPeripheralIDs: Set<String> = []

    @Published var discoveredMessages: [String] = []
    @Published var isScanningEnabled: Bool = true
    private var recentlyFetchedHashes: Set<String> = [] // ✅ 중복 방지용

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionRestoreIdentifierKey: "HaloBLECentral"
        ])

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            print("🔔 알림 권한: \(granted), 오류: \(String(describing: error))")
        }
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            print("⏳ BLE 상태가 준비되지 않음: \(centralManager.state.rawValue)")
            return
        }

        guard isScanningEnabled else {
            print("🚫 스캔 요청 무시됨 (비활성화 상태)")
            return
        }

        centralManager.scanForPeripherals(withServices: [targetServiceUUID], options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
        print("🔍 BLE 스캔 시작됨")
    }

    func stopScanning() {
        centralManager?.stopScan()
        print("🛑 BLE 스캔 중지됨")
    }

    func resetDiscoveredPeers() {
        DispatchQueue.main.async {
            self.discoveredMessages.removeAll()
            self.receivedPeripheralIDs.removeAll()
            print("🔄 수신 피어 및 메시지 초기화 완료")

            self.stopScanning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.centralManager.state == .poweredOn, self.isScanningEnabled {
                    self.startScanning()
                    print("🔁 초기화 후 BLE 스캔 재시작됨")
                }
            }
        }
    }

    private func restartScanImmediately() {
        guard isScanningEnabled else { return }
        centralManager.stopScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.centralManager.state == .poweredOn else { return }
            self.centralManager.scanForPeripherals(withServices: [self.targetServiceUUID], options: nil)
            print("🔁 즉시 BLE 스캔 재시작됨")
        }
    }

    private func triggerLocalNotification(with message: String) {
        let content = UNMutableNotificationContent()
        content.title = "HaloZone"
        content.body = "주변 러너중에 대화를 원치 않는 사람이 있어요!"
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func fetchProfileForDiscoveredHash(_ hash: String) {
        guard !recentlyFetchedHashes.contains(hash) else { return }
        recentlyFetchedHashes.insert(hash)

        DispatchQueue.global(qos: .background).async {
            ProfileAPIService.shared.fetchProfiles(for: [hash]) { result in
                switch result {
                case .success(let profiles):
                    print("🌐 서버 응답 프로필 수: \(profiles.count)")
                    for p in profiles {
                        print("👤 \(p.nickname), \(p.userHash)")
                    }
                    saveNearbyProfilesToLocal(profiles)
                case .failure(let error):
                    print("❌ 프로필 요청 실패: \(error)")
                }
            }
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BLECentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if isScanningEnabled {
                startScanning()
            }
        } else {
            print("⚠️ BLE 상태 변경됨: \(central.state.rawValue)")
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {

        guard let rawMessage = advertisementData[CBAdvertisementDataLocalNameKey] as? String else {
            print("⚠️ 광고에 로컬 이름 없음 → 무시")
            return restartScanImmediately()
        }

        let senderHash = rawMessage

        guard RSSI.intValue > -70 else {
            print("📶 RSSI 낮음 (\(RSSI.intValue)) → 무시")
            return restartScanImmediately()
        }

        guard senderHash != localDeviceID else {
            print("🙈 자기 자신의 메시지 → 무시")
            return restartScanImmediately()
        }

        let now = Date()
        if let lastSeen = recentPeerTimestamps[senderHash],
           now.timeIntervalSince(lastSeen) < 60 {
            print("⏱️ 최근 수신된 피어 (\(senderHash)), 무시")
            return restartScanImmediately()
        }

        recentPeerTimestamps[senderHash] = now

        print("📨 새로운 피어 감지: \(senderHash)")

        DispatchQueue.main.async {
            self.discoveredMessages.append(senderHash)
            self.triggerLocalNotification(with: "새로운 해시 수신: \(senderHash)")
        }

        fetchProfileForDiscoveredHash(senderHash)

        centralManager.stopScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("🔁 복원된 BLE 상태: \(dict)")
        self.centralManager = central
        if isScanningEnabled {
            startScanning()
        }
    }
}
