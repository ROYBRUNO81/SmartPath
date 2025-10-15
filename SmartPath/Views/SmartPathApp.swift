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
    ClassRecord.self,
    StreakRecord.self,
    OtherEventRecord.self
  )
  
  init() {
    // No sample data - user will add their own data
  }

  var body: some Scene {
    WindowGroup {
      AppRootView()
        .modelContainer(container)
    }
  }
}
