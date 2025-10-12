//
//  Theme.swift
//  SmartPath
//
//  Created by Assistant on 10/12/25.
//

import SwiftUI

extension Color {
    static let spBackground = Color(hex: "#F5F7F3")
    static let spPrimary    = Color(hex: "#3D8B7D")
    static let spSecondary  = Color(hex: "#2C5F54")

    init(hex: String) {
        let r, g, b, a: Double

        var hexColor = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if hexColor.hasPrefix("#") { hexColor.removeFirst() }

        var int: UInt64 = 0
        Scanner(string: hexColor).scanHexInt64(&int)
        switch hexColor.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
            a = 1.0
        case 8:
            r = Double((int >> 24) & 0xFF) / 255.0
            g = Double((int >> 16) & 0xFF) / 255.0
            b = Double((int >> 8) & 0xFF) / 255.0
            a = Double(int & 0xFF) / 255.0
        default:
            r = 1; g = 1; b = 1; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}


