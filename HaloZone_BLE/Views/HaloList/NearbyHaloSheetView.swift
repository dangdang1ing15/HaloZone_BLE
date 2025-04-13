import SwiftUI

struct NearbyHaloSheetView: View {
    @State var isAngel = false
    
    var body: some View {
        VStack{
            VStack{
                Text("내 주변 천사들")
                    .font(.headline)

                Text("10미터 이내 3명")
                    .font(.subheadline)
            }
            .padding(.bottom, 10)
            MyProfileView()
            .padding(.bottom, 10)
            NearbyHaloListView()
        }
    }
}

#Preview {
    NearbyHaloSheetView()
}
