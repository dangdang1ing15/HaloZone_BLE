import SwiftUI

struct NearbyHaloListView: View {
    @ObservedObject var viewModel: NearbyHaloListViewModel

    var body: some View {
        List {
            ForEach(viewModel.profiles) { profile in
                NearbyHaloProfileView(profile: profile)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.thinMaterial)
        .frame(maxWidth: .infinity)
        .cornerRadius(20)
    }
}


#Preview {
    @Previewable var viewModel = NearbyHaloListViewModel()
    
    NearbyHaloListView(viewModel: viewModel)
}
