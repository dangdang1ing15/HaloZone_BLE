import SwiftUI

struct NearbyHaloProfileView: View {
    let profile: HaloProfile

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
                    // 😇 or 🤔 이모지
                    Text(profile.emoji)
                        .font(.system(size:45))
                    
                    VStack(alignment: .leading) {
                        Text(profile.name)
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("\"\(profile.message)\"")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}
