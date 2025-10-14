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
  
  init() {
    // Populate sample data on first launch
    let context = container.mainContext
    SampleDataService.populateSampleData(context: context)
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .modelContainer(container)
    }
  }
}
