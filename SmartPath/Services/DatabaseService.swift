//
//  DatabaseService.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import Foundation
import SwiftData

/// A shared container for all your models
@MainActor
class DataService {
  static let shared = DataService()
  let container: ModelContainer

  private init() {
    container = try! ModelContainer(
      for: Student.self,
      Major.self,
      Course.self,
      Schedule.self
    )
  }

  // MARK: Student

  func fetchStudent() -> Student? {
    let context = container.mainContext
    return try? context.fetch(FetchDescriptor<Student>()).first
  }

  func saveStudent(_ student: Student) {
    let context = container.mainContext
    try? context.save()
  }

  // MARK: Courses

  func fetchAllCourses() -> [Course] {
    let context = container.mainContext
    return (try? context.fetch(FetchDescriptor<Course>())) ?? []
  }

  func upsertCourse(_ course: Course) {
    let context = container.mainContext
    try? context.save()
  }

  // MARK: Schedule

  func fetchSchedule() -> Schedule? {
    let context = container.mainContext
    return try? context.fetch(FetchDescriptor<Schedule>()).first
  }

  func saveSchedule(_ schedule: Schedule) {
    let context = container.mainContext
    try? context.save()
  }
}

