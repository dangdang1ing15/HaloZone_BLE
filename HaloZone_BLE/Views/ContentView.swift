import SwiftUI

struct ContentView: View {
    @StateObject private var peripheralManager = BLEPeripheralManager.shared
    @StateObject private var centralManager = BLECentralManager.shared

    @State private var isSending = false
    @State private var isReceiving = false
    @State private var message = "HaloZone에서 안녕하세요!"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("보낼 메시지 입력", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Toggle("📤 자동 전송 모드 (Peripheral)", isOn: $isSending)
                    .onChange(of: isSending) { isOn in
                        if isOn {
                            peripheralManager.startAdvertising(message: message)
                        } else {
                            peripheralManager.stopAdvertising()
                        }
                    }
                    .padding(.horizontal)

                Toggle("📥 수신 모드 (Central)", isOn: $isReceiving)
                    .onChange(of: isReceiving) { isOn in
                        centralManager.isScanningEnabled = isOn
                        if isOn {
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
                            centralManager.startScanning()
                        } else {
                            centralManager.stopScanning()
                        }
                    }
                    .padding(.horizontal)
                Button("초기화") {
                    centralManager.resetDiscoveredPeers()
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                List(centralManager.discoveredMessages, id: \.self) { msg in
                    Text("🔔 \(msg)")
                }
            }
            .navigationTitle("BLE 메시지 테스트")
        }
    }
}

#Preview {
    ContentView()
}
