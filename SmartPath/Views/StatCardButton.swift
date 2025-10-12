//
//  StatCardButton.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 10/12/25.
//

import SwiftUI

struct StatCardButton: View {
    let emoji: String
    let title: String
    let count: Int
    let subtitle: String
    let gradientColors: [Color]
    let countColor: Color
    let action: (() -> Void)? = nil

    var body: some View {
        let card = VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(emoji)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
            }

            Text("\(count)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(countColor)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 120)
        .padding(16)
        .background(
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.spSecondary.opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

        if let action {
            Button(action: action) { card }
                .buttonStyle(.plain)
        } else {
            card
        }
    }
}


