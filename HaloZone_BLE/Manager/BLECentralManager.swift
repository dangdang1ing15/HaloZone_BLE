import Foundation
import CoreBluetooth
import UserNotifications
import UIKit

class BLECentralManager: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    private let targetServiceUUID = CBUUID(string: "1234")
    private let localDeviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    private var receivedPeripheralIDs: Set<String> = []

    @Published var discoveredMessages: [String] = []
    @Published var isScanningEnabled: Bool = true

    func startScanning() {
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil, options: [
                CBCentralManagerOptionRestoreIdentifierKey: "HaloBLECentral"
            ])
        } else {
            centralManager.scanForPeripherals(
                withServices: [targetServiceUUID],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            )
            print("🔍 BLE 스캔 재시작")
        }
    }

    func resetDiscoveredPeers() {
        DispatchQueue.main.async {
            self.discoveredMessages.removeAll()
            self.receivedPeripheralIDs.removeAll()
            print("🔄 수신 피어 및 메시지 초기화 완료")

            self.centralManager.stopScan()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.centralManager.scanForPeripherals(
                    withServices: [self.targetServiceUUID],
                    options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
                )
                print("🔁 초기화 후 BLE 스캔 재시작됨")
            }
        }
    }

    private func triggerLocalNotification(with message: String) {
        let content = UNMutableNotificationContent()
        content.title = "📥 주변에서 메시지 수신"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func restartScanImmediately() {
        guard isScanningEnabled else {
            print("🚫 스캔 비활성화 상태, 재시작하지 않음")
            return
        }

        centralManager.stopScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.centralManager.state == .poweredOn else {
                print("⚠️ BLE 꺼짐 상태, 재시작 생략")
                return
            }

            self.centralManager.scanForPeripherals(withServices: [self.targetServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            print("🔁 즉시 BLE 스캔 재시작됨")
        }
    }

    
    func stopScanning() {
        centralManager?.stopScan()
        print("🛑 BLE 스캔 중지됨")
    }

}

extension BLECentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(
                withServices: [targetServiceUUID],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            )
            print("🔍 BLE 스캔 시작")
        } else {
            print("⚠️ BLE 스캔 불가: 상태 - \(central.state.rawValue)")
        }
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("🔁 백그라운드에서 BLE 상태 복원됨: \(dict)")
        centralManager.scanForPeripherals(
            withServices: [targetServiceUUID],
            options: nil
        )
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {

        guard let rawMessage = advertisementData[CBAdvertisementDataLocalNameKey] as? String else {
            print("⚠️ 메시지가 없는 광고 무시")
            restartScanImmediately()
            return
        }

        let components = rawMessage.components(separatedBy: "::")
        guard components.count == 3, components[0] == "halo" else {
            print("⚠️ 유효하지 않은 메시지 형식 무시")
            restartScanImmediately()
            return
        }
        
        guard RSSI.intValue > -60 else {
            print("⚠️ RSSI \(RSSI.intValue) → 거리 제한으로 무시")
            restartScanImmediately()
            return
        }


        let senderID = components[1]
        let actualMessage = components[2]

        guard senderID != localDeviceID else {
            print("⚠️ 자기 자신의 메시지 감지됨, 무시")
            restartScanImmediately()
            return
        }

        guard !receivedPeripheralIDs.contains(senderID) else {
            print("⚠️ 이미 수신한 피어: \(senderID), 무시")
            restartScanImmediately()
            return
        }

        receivedPeripheralIDs.insert(senderID)

        print("📨 새로운 피어 감지: \(senderID)")
        print("💬 메시지: \(actualMessage)")

        DispatchQueue.main.async {
            self.discoveredMessages.append("\(senderID): \(actualMessage)")
            self.triggerLocalNotification(with: actualMessage)
        }

        centralManager.stopScan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.centralManager.scanForPeripherals(
                withServices: [self.targetServiceUUID],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            )
            print("🔁 BLE 스캔 재시작됨")
        }
    }
}
