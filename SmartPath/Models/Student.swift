//
//  Student.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import Foundation

struct Student: Codable, Identifiable {
    let id: String              // student identifier
    var name: String
    var schoolYear: String      // "Freshman", "Sophomore", etc.
    var term: String            // "Fall", "Spring", "Summer"
    var gpa: Double?
    
    init(id: String,
         name: String,
         schoolYear: String,
         term: String,
         gpa: Double? = nil) {
        self.id = id
        self.name = name
        self.schoolYear = schoolYear
        self.term = term
        self.gpa = gpa
    }
}
