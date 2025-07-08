//
//  PlanViewModel.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/7/25.
//

import Foundation
import Combine

struct SemesterSummary { let credits: Double; let avgDifficulty: Double }

@MainActor
class PlanViewModel: ObservableObject {
  @Published var student: Student
  @Published var summaries: [SemesterSummary] = []
  
  init(student: Student) {
    self.student = student
    computeSummaries()
  }
  
    func move(course code: String, to semester: Int) {
    student.schedule.move(course: code, to: semester)
    DataService.shared.saveStudent(student)
    DataService.shared.saveSchedule(student.schedule)
    computeSummaries()
  }
  
    private func computeSummaries() {
    summaries = student.schedule.coursesBySemester.map { codes in
      let courses = DataService.shared.fetchAllCourses()
        .filter { codes.contains($0.code) }
      let credits = courses.reduce(0) { $0 + $1.credit }
      let avgDiff = courses.isEmpty ? 0 :
        courses.reduce(0) { $0 + $1.difficulty } / Double(courses.count)
      return SemesterSummary(credits: credits, avgDifficulty: avgDiff)
    }
  }
}
