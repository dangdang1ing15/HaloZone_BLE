import SwiftUI

struct HaloMainView: View {
    @State private var isHaloEnabled = false
    @StateObject private var timerManager = HaloTimerManager()
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            ZStack {
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
                    NearbyHaloButtonView(isHaloEnabled: $isHaloEnabled,
                                         isEditing: $isEditing)
                }
            }
            .onChange(of: isHaloEnabled) { newValue in
                if newValue {
                    timerManager.start()
                } else {
                    timerManager.stop()
                }
            }
        }
    }

}


#Preview {
    HaloMainView()
}
