//
//  Major.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import SwiftData

@Model
class Major {
  var name: String
  var requiredCourses: [String]
  var creditRequired: Int
  
  init(name: String, requiredCourses: [String], creditRequired: Int) {
    self.name            = name
    self.requiredCourses = requiredCourses
    self.creditRequired  = creditRequired
  }
}
