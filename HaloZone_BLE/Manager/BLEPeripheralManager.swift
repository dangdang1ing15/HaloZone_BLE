//
//  BLEPeripheralManager.swift
//  HaloZone_BLE
//
//  Created by 성현 on 4/12/25.
//

import Foundation
import CoreBluetooth
import UIKit

class BLEPeripheralManager: NSObject, ObservableObject {
    private var peripheralManager: CBPeripheralManager!
    private let serviceUUID = CBUUID(string: "1234")
    private let advertisedName = "HaloBLE"
    private var messageToBroadcast: String = ""
    private var deviceID: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    private var deviceHash: String {
        let fullID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let hash = fullID.hashValue
        return String(format: "%04X", abs(hash) % 0xFFFF)
    }

    func startAdvertising(message: String) {
        let formattedMessage = "halo::\(deviceHash)::\(message)"
        self.messageToBroadcast = formattedMessage
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    // 정지
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
