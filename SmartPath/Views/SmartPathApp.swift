//
//  SmartPathApp.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

// SmartPathApp.swift
import SwiftUI
import SwiftData

@main
struct SmartPathApp: App {
  // Create the container once
  let container = try! ModelContainer(
    for: Student.self,
    Major.self,
    Course.self,
    Schedule.self,
    TaskRecord.self,
    ExamRecord.self,
    ClassRecord.self
  )

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        ContentView()
      }
      .modelContainer(container)
    }
  }
}
