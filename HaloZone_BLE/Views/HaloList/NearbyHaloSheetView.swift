import SwiftUI

struct NearbyHaloSheetView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @StateObject private var peripheralManager = BLEPeripheralManager()
    @StateObject private var centralManager = BLECentralManager()

    @State private var isSending = false
    @State private var isReceiving = false
    @State private var message = "HaloZone에서 안녕하세요!"
    @State var isAngel = false
    @State private var showPopover = false

    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    // 기능 없음
                }) {
                    Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                        .font(.title2)
                        .foregroundColor(.primary)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("내 주변 천사들")
                        .font(.headline)

                    Text("10미터 이내 3명")
                        .font(.subheadline)
                }

                Spacer()

                Button(action: {
                    showPopover.toggle()
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .popover(isPresented: $showPopover, arrowEdge: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("📡 백그라운드 탐색 모드", isOn: $isReceiving)
                            .onChange(of: isReceiving) { isOn in
                                centralManager.isScanningEnabled = isOn
                                if isOn {
                                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
                                    centralManager.startScanning()
                                } else {
                                    centralManager.stopScanning()
                                }
                            }

                        Divider()

                        Button("🔁 초기화") {
                            centralManager.resetDiscoveredPeers()
                        }

                        Divider()

                        Text("🔔 수신 메시지")
                            .font(.headline)

                        ScrollView {
                            ForEach(centralManager.discoveredMessages, id: \.self) { msg in
                                Text("• \(msg)")
                                    .font(.subheadline)
                            }
                        }
                        .frame(height: 100)
                    }
                    .padding()
                    .frame(width: 250)
                }

            }
            .padding(.horizontal)
            .padding(.top, 8)

            MyProfileView(profileVM: profileVM)
                .padding(.bottom, 10)

            NearbyHaloListView()
        }

    }
}
