//
//  CatalogViewModel.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/7/25.
//

import Foundation
import Combine

@MainActor
class CatalogViewModel: ObservableObject {
  @Published var courseCode     = ""
  @Published var fetchedDetail: CourseDetail?
  @Published var isLoading      = false
  @Published var error: Error?

  private var fetchTask: Task<Void,Never>?
  private let dataService = DataService.shared

  func fetch() {
    isLoading = true
    error     = nil
    fetchedDetail = nil
    Task { @MainActor in
          do {
            let detail = try await CatalogService.shared.fetchCourseDetail(code: courseCode)
            fetchedDetail = detail
          } catch {
            self.error = error
          }
          isLoading = false
    }
  }

  func addToPlan() {
    guard let detail = fetchedDetail else { return }

    // 1) Build the persistent Course model
    let course = Course(
      code:             detail.code,
      title:            detail.title,
      detail:           detail.description,
      credit:           detail.credit ?? 0,
      difficulty:       detail.difficulty,
      semestersOffered: detail.semestersOffered,
      weeklyHours:      detail.weeklyHours,
      prerequisites:    detail.prerequisites
    )

    // 2) Persist it
    dataService.upsertCourse(course)

    // 3) Update the student's current schedule
    if let student  = dataService.fetchStudent(),
       let schedule = dataService.fetchSchedule() {
      schedule.add(course: course.code, to: student.schedule.currentSemesterIndex)
      dataService.saveSchedule(schedule)
    }

    // 4) Reset
    fetchedDetail = nil
  }
}

