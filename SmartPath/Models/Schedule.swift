//
//  Schedule.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import SwiftData

@Model
class Schedule {
  // 8 semesters arrays of course codes
  var coursesBySemester: [[String]]
  
  init(coursesBySemester: [[String]] = Array(repeating: [], count: 8)) {
    self.coursesBySemester = coursesBySemester
  }
  
  var currentSemesterIndex: Int {
    // derive from student.schoolYear & term if needed
    0
  }
  
  func add(course code: String, to semester: Int) {
    guard semester < coursesBySemester.count else { return }
    if !coursesBySemester[semester].contains(code) {
      coursesBySemester[semester].append(code)
    }
  }
  
  func move(course code: String, to semester: Int) {
    // remove from others
    for i in coursesBySemester.indices {
      coursesBySemester[i].removeAll { $0 == code }
    }
    add(course: code, to: semester)
  }
}

