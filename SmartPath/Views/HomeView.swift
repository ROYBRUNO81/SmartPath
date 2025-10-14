//
//  p.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/7/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        GradientBackground()
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
    }
}
