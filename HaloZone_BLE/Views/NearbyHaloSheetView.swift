import SwiftUI

struct NearbyHaloSheetView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @ObservedObject var peripheralManager: BLEPeripheralManager
    @ObservedObject var centralManager: BLECentralManager
    
    @StateObject private var viewModel = NearbyHaloListViewModel()

    @State private var isActivated = true
    @State private var message = "HaloZone에서 안녕하세요!"
    @State var isAngel = false
    @State private var showPopover = false
    @State private var reloadNearbyList = false
    
    var scale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    viewModel.syncWithServer()
                }) {
                    Image("Arrow_Clockwise")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("내 주변 천사들")
                        .font(.headline)

                    Text("10미터 이내 \(viewModel.profiles.count)명")
                        .font(.subheadline)
                }

                Spacer()

                Button(action: {
                    isActivated.toggle()
                    centralManager.isScanningEnabled = isActivated

                    if isActivated {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
                        centralManager.startScanning()
                    } else {
                        centralManager.stopScanning()
                    }
                }) {
                    Image(isActivated ? "Bluetooth_on" : "Bluetooth_off")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            MyProfileView(profileVM: profileVM)
                .padding(.bottom, 10)

            NearbyHaloListView(viewModel: viewModel)
        }
    }
}
