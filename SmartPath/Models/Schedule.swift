//
//  Schedule.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import Foundation

struct Semester: Codable, Identifiable {
    let id: Int
    var courses: [String]

    init(id: Int, courses: [String] = []) {
        self.id = id
        self.courses = courses
    }
}

struct Plan: Codable {
    var semesters: [Semester]

    init() {
        self.semesters = (0..<8).map { Semester(id: $0) }
    }
}
