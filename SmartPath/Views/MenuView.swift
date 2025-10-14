//
//  MenuView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/11/25.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        GradientBackground()
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
    }
}
