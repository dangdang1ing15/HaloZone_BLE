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

#Preview {
    // 예시로 loadHaloProfiles()의 첫번째 데이터를 사용
    if let sampleProfile = loadHaloProfiles().first {
        NearbyHaloProfileView(profile: sampleProfile)
    } else {
        // 데이터가 없으면 기본값 사용
        NearbyHaloProfileView(profile: HaloProfile(name: "Sample", message: "Sample Message", isAngel: false))
    }
}
