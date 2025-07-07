//
//  Major.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import Foundation

struct Major: Codable {
    var name: String
    var requiredCourses: Set<String>
    var creditRequired: Int

    init(name: String,
         requiredCourses: Set<String> = [],
         creditRequired: Int = 0) {
        self.name = name
        self.requiredCourses = requiredCourses
        self.creditRequired = creditRequired
    }
}
