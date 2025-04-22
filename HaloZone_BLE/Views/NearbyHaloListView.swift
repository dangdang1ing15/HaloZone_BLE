import SwiftUI

struct NearbyHaloListView: View {
    @ObservedObject var viewModel: NearbyHaloListViewModel

    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(viewModel.profiles.indices, id: \.self) { index in
                    let profile = viewModel.profiles[index]

                    NearbyHaloProfileView(profile: profile)
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.profiles.remove(at: index)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(.thinMaterial)
            .cornerRadius(20) // ✅ safe area bottom 패딩
        }
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.profiles.remove(atOffsets: offsets)
    }
}
