//
//  CircleView.swift
//  HaloZone_BLE
//
//  Created by 성현 on 4/13/25.
//

import SwiftUI

struct CircleView: View {
    let initialState: Bool
       @State private var currentState: Bool

   init(state: Bool) {
       self.initialState = state
       self._currentState = State(initialValue: state)
   }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 100, height: 100)
                .shadow(radius: 7)
            
            Text(currentState ? "😇" : "🤔")
                .font(.system(size: 60))
        }
    }
}


#Preview {
    CircleView(state: true)
}
