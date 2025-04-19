import SwiftUI

struct NearbyHaloListView: View {
    @ObservedObject var viewModel: NearbyHaloListViewModel

    var body: some View {
        List {
            ForEach(viewModel.profiles) { profile in
                NearbyHaloProfileView(profile: .init(
                    name: profile.nickname,
                    message: profile.statusMessage,
                    isAngel: profile.isHaloEnabled
                ))
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.thinMaterial)
        .cornerRadius(20)
        .onAppear {
            viewModel.loadProfiles(from: ["A1B2", "C3D4"]) // ← 이 부분은 BLE로 받은 해시들로 대체해야 해
        }
    }
}
