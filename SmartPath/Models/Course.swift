//
//  Course.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import SwiftData

@Model
class Course {
  @Attribute(.unique) var code: String
  var title: String
  var detail: String
  var credit: Double
  var difficulty: Double
  var semestersOffered: [String]
  var weeklyHours: [String: [Int]]
  var prerequisites: [String]
  
  init(code: String,
       title: String,
       detail: String,
       credit: Double,
       difficulty: Double,
       semestersOffered: [String],
       weeklyHours: [String: [Int]],
       prerequisites: [String])
  {
    self.code             = code
    self.title            = title
    self.detail           = detail
    self.credit           = credit
    self.difficulty       = difficulty
    self.semestersOffered = semestersOffered
    self.weeklyHours      = weeklyHours
    self.prerequisites    = prerequisites
  }
}
