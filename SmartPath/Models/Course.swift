//
//  Course.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import Foundation

struct Course: Codable, Identifiable {
    let id: String            // same as code
    var code: String          // e.g. "MATH 1400"
    var title: String
    var description: String
    var credit: Double?
    var difficulty: Double    // 1.0–4.0
    var prerequisites: [String]
    var semestersOffered: [String]
    var weeklyHours: [String: [Int]] // e.g. ["Monday": [900, 1030]]

    init(code: String,
         title: String,
         description: String = "",
         credit: Double? = nil,
         difficulty: Double = 1.0,
         prerequisites: [String] = [],
         semestersOffered: [String] = [],
         weeklyHours: [String: [Int]] = [:]) {
        self.id = code
        self.code = code
        self.title = title
        self.description = description
        self.credit = credit
        self.difficulty = difficulty
        self.prerequisites = prerequisites
        self.semestersOffered = semestersOffered
        self.weeklyHours = weeklyHours
    }
}
