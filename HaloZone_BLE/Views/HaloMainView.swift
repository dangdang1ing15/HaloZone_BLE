import SwiftUI

struct HaloMainView: View {
    @State private var isHaloEnabled = false
    @StateObject private var timerManager = HaloTimerManager()
    @State private var isEditing = false
    @Namespace private var animation
    @StateObject private var profileVM = ProfileViewModel()
    @StateObject private var peripheralManager = BLEPeripheralManager.shared

    
    @State private var message = "방.금.모"
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isEditing {
                        Color.black.opacity(0.3) // 배경 딤 처리
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    isEditing = false
                                }
                            }

                        EditProfileSheetView(profileVM: profileVM, isEditing: $isEditing, animation: animation)
                            .transition(.move(edge: .bottom))
                            .zIndex(2)
                    }
                (isHaloEnabled ? Color(red: 92/255, green: 92/255, blue: 92/255)
                               : Color(red: 248/255, green: 192/255, blue: 60/255))
                .ignoresSafeArea()

                VStack {
                    Text(isHaloEnabled ? "헤일로존 활성화" : "천사 탐색 중")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 100)

                    if isHaloEnabled {
                        Text(timerManager.formattedTime())
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }

                    HaloEnableButtonView(isHaloEnabled: $isHaloEnabled)
                        .padding(.top, 60)

                    Spacer()
                }

                VStack {
                    Spacer()
                    NearbyHaloButtonView(
                        profileVM: profileVM,
                        isHaloEnabled: $isHaloEnabled,
                        isEditing: $isEditing
                    )
                    .id("\(profileVM.profile.lastmodified)-\(isHaloEnabled)")

                }
            }
            .onChange(of: isHaloEnabled) { newValue in
                if newValue {
                    timerManager.start()
                    profileVM.updateIsAngel(true)

                    // 📤 peripheral 광고 시작
                    peripheralManager.startAdvertising(message: message)
                } else {
                    timerManager.stop()
                    profileVM.updateIsAngel(false)

                    // 📤 peripheral 광고 중지
                    peripheralManager.stopAdvertising()
                }
            }


            .animation(.easeInOut, value: isEditing)
        }
    }

}


#Preview {
    HaloMainView()
}
