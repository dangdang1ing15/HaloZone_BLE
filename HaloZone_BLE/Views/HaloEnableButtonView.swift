//
//  HaloEnableButtonView.swift
//  HaloZone_BLE
//
//  Created by 성현 on 4/13/25.
//

import SwiftUI

struct HaloEnableButtonView: View {
    @Binding var isHaloEnabled: Bool
    
    var body: some View {
        Button(action: {
            isHaloEnabled.toggle()
        }) {
            LottieView(
                    fileName: isHaloEnabled ? "HaloRing_Yellow" : "HaloRing_White",
                    loopMode: .loop
                )
                .scaledToFit()
        }
    }
}
