//
//  Student.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import SwiftData

@Model
class Student {
  @Attribute(.unique) var studentID: String
  var name: String
  var schoolYear: String
  var term: String
  var gpa: Double
  
  // One-to-one
  var major: Major
  
  // Owns a Schedule instance
  var schedule: Schedule
  
  init(studentID: String,
       name: String,
       schoolYear: String,
       term: String,
       gpa: Double,
       major: Major,
       schedule: Schedule)
  {
    self.studentID  = studentID
    self.name       = name
    self.schoolYear = schoolYear
    self.term       = term
    self.gpa        = gpa
    self.major      = major
    self.schedule   = schedule
  }
}
