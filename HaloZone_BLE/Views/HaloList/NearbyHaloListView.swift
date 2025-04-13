//
//  NearbyHaloListView.swift
//  HaloZone_BLE
//
//  Created by 성현 on 4/13/25.
//

import SwiftUI

import SwiftUI

struct NearbyHaloListView: View {
    let profiles = loadHaloProfiles()

    var body: some View {
        List {
            ForEach(profiles) { profile in
                NearbyHaloProfileView(profile: profile)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.thinMaterial)
        .cornerRadius(20)
    }
}

