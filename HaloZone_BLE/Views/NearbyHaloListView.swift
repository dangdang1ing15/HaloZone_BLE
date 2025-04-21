import SwiftUI

struct NearbyHaloListView: View {
    @ObservedObject var viewModel: NearbyHaloListViewModel

    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(viewModel.profiles) { profile in
                    NearbyHaloProfileView(profile: profile)
                        .listRowBackground(Color.clear)
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(.thinMaterial)
            .frame(maxWidth: .infinity)
            .cornerRadius(20)
            .padding(.bottom, geometry.safeAreaInsets.bottom + 30) // ✅ safe area bottom 패딩
        }
    }
}
