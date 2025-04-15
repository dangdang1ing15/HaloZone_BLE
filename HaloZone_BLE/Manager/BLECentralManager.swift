import Foundation
import CoreBluetooth
import UserNotifications
import UIKit

class BLECentralManager: NSObject, ObservableObject {
    private(set) var centralManager: CBCentralManager!
    private let targetServiceUUID = CBUUID(string: "1234")
    private let localDeviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    private var receivedPeripheralIDs: Set<String> = []

    @Published var discoveredMessages: [String] = []
    @Published var isScanningEnabled: Bool = true

    override init() {
        super.init()

        // 백그라운드 복원을 위한 ID 설정
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionRestoreIdentifierKey: "HaloBLECentral"
        ])

        // 앱 처음 실행 시 알림 권한 요청
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
        content.title = "📥 주변에서 메시지 수신"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

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

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("🔁 백그라운드에서 BLE 상태 복원됨")
        self.centralManager = central
        if isScanningEnabled {
            startScanning()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let rawMessage = advertisementData[CBAdvertisementDataLocalNameKey] as? String else {
            return restartScanImmediately()
        }

        let components = rawMessage.components(separatedBy: "::")
        guard components.count == 3, components[0] == "halo" else {
            return restartScanImmediately()
        }

        guard RSSI.intValue > -60 else {
            return restartScanImmediately()
        }

        let senderID = components[1]
        let actualMessage = components[2]

        guard senderID != localDeviceID, !receivedPeripheralIDs.contains(senderID) else {
            return restartScanImmediately()
        }

        receivedPeripheralIDs.insert(senderID)

        print("📨 새로운 피어 감지: \(senderID) / 메시지: \(actualMessage)")
        DispatchQueue.main.async {
            self.discoveredMessages.append("\(senderID): \(actualMessage)")
            self.triggerLocalNotification(with: actualMessage)
        }

        // 1초 후 재스캔
        centralManager.stopScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startScanning()
        }
    }
}
