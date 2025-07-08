//
//  ProfileViewModel.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/7/25.
//

import Foundation
import Combine
import SwiftData

class ProfileViewModel: ObservableObject {
  @Published var student: Student = {
      DataService.shared.fetchStudent() ??
      Student(studentID: "", name: "", schoolYear: "", term: "", gpa: 0,
              major: Major(name: "", requiredCourses: [], creditRequired: 0),
              schedule: Schedule())
  }()
  
  func save() {
    DataService.shared.saveStudent(student)
  }
}
