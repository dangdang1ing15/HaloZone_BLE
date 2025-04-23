import Foundation
import CoreBluetooth
import UIKit

class BLEPeripheralManager: NSObject, ObservableObject {
    let profile = loadProfile()
    private var peripheralManager: CBPeripheralManager!
    private let serviceUUID = CBUUID(string: "1234")
    private var messageToBroadcast: String = ""

    func startAdvertising() {
        messageToBroadcast = profile.userHash
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func stopAdvertising() {
        peripheralManager?.stopAdvertising()
    }
}

extension BLEPeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let advertisementData: [String: Any] = [
                CBAdvertisementDataLocalNameKey: messageToBroadcast,
                CBAdvertisementDataServiceUUIDsKey: [serviceUUID]
            ]
            peripheralManager.startAdvertising(advertisementData)
            print("📡 광고 시작됨: \(messageToBroadcast)")
        } else {
            print("⚠️ BLE가 켜져있지 않음")
        }
    }
}
