//
//  HomeViewModel.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/7/25.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
  @Published var student: Student
  
  init(student: Student) {
    self.student = student
  }
  
  var currentCourses: [String] {
    let idx = student.schedule.currentSemesterIndex
    return student.schedule.coursesBySemester[idx]
  }
  
  var totalCredits: Double {
    DataService.shared.fetchAllCourses()
      .filter { currentCourses.contains($0.code) }
      .reduce(0) { $0 + $1.credit }
  }
}
