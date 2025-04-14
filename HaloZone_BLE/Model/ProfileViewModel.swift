import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var profile: MyProfile = loadProfile()

    func updateName(_ name: String) {
        profile.name = name
        profile.lastmodified = formattedNow()
        saveProfile(profile)
    }

    func updateMessage(_ message: String) {
        var updated = profile
        updated.message = message
        updated.lastmodified = formattedNow()
        profile = updated
        saveProfile(profile)
    }


    func updateIsAngel(_ isAngel: Bool) {
        var newProfile = profile
        newProfile.isAngel = isAngel
        newProfile.lastmodified = formattedNow()
        profile = newProfile
        saveProfile(newProfile)
    }




    func reload() {
        profile = loadProfile()
    }

    private func formattedNow() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
}
