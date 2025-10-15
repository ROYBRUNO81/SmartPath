//
//  AddModels.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 10/12/25.
//

import SwiftData
import Foundation

@Model
class TaskRecord: Hashable {
  var title: String
  var details: String
  var occurs: String // "Once" or "Repeating"
  var dueDate: Date // For "Once" tasks
  var dueTime: Date
  var colorHex: String
  // For repeating tasks
  var days: [String] // Days of week for repeating
  var startDate: Date? // Start date for repeating
  var endDate: Date? // End date for repeating
  // Completion tracking
  var isCompleted: Bool = false
  var completionPercentage: Int = 0 // 0-100

  init(title: String, details: String, occurs: String, dueDate: Date, dueTime: Date, days: [String] = [], startDate: Date? = nil, endDate: Date? = nil, colorHex: String = "") {
    self.title = title
    self.details = details
    self.occurs = occurs
    self.dueDate = dueDate
    self.dueTime = dueTime
    self.days = days
    self.startDate = startDate
    self.endDate = endDate
    self.colorHex = colorHex.isEmpty ? Self.randomColor() : colorHex
  }
  
  static func randomColor() -> String {
    let colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2", "#F8B195", "#C06C84"]
    return colors.randomElement() ?? "#4ECDC4"
  }
  
  static func == (lhs: TaskRecord, rhs: TaskRecord) -> Bool {
    return lhs.title == rhs.title && lhs.dueDate == rhs.dueDate && lhs.dueTime == rhs.dueTime
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(title)
    hasher.combine(dueDate)
    hasher.combine(dueTime)
  }
}

@Model
class ExamRecord {
  var name: String
  var examType: String // "Midterm 1", "Midterm 2", "Final", "Quiz", "Other"
  var customType: String // For "Other" type
  var mode: String // In Person, Online
  var room: String
  var building: String
  var link: String // For online mode
  var date: Date // Single date for non-repeating
  var time: Date
  var durationMinutes: Int
  var colorHex: String
  // For repeating quizzes
  var isRepeating: Bool
  var days: [String] // Days of week for repeating quizzes
  var startDate: Date? // Start date for repeating
  var endDate: Date? // End date for repeating
  // Completion tracking
  var isCompleted: Bool = false

  init(name: String, examType: String, customType: String = "", mode: String, room: String, building: String, link: String = "", date: Date, time: Date, durationMinutes: Int, isRepeating: Bool = false, days: [String] = [], startDate: Date? = nil, endDate: Date? = nil, colorHex: String = "") {
    self.name = name
    self.examType = examType
    self.customType = customType
    self.mode = mode
    self.room = room
    self.building = building
    self.link = link
    self.date = date
    self.time = time
    self.durationMinutes = durationMinutes
    self.isRepeating = isRepeating
    self.days = days
    self.startDate = startDate
    self.endDate = endDate
    self.colorHex = colorHex.isEmpty ? Self.randomColor() : colorHex
  }
  
  static func randomColor() -> String {
    let colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2", "#F8B195", "#C06C84"]
    return colors.randomElement() ?? "#4ECDC4"
  }
}

@Model
class ClassRecord {
  var mode: String // In Person, Online
  var className: String
  var room: String
  var building: String
  var teacher: String
  var days: [String] // Mon..Sun - days of week this class occurs
  var startTime: Date // Time of day class starts
  var endTime: Date // Time of day class ends
  var startDate: Date // First date of the class
  var endDate: Date // Last date of the class
  var colorHex: String

  init(mode: String, className: String, room: String, building: String, teacher: String, days: [String], startTime: Date, endTime: Date, startDate: Date, endDate: Date, colorHex: String = "") {
    self.mode = mode
    self.className = className
    self.room = room
    self.building = building
    self.teacher = teacher
    self.days = days
    self.startTime = startTime
    self.endTime = endTime
    self.startDate = startDate
    self.endDate = endDate
    self.colorHex = colorHex.isEmpty ? Self.randomColor() : colorHex
  }
  
  static func randomColor() -> String {
    let colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2", "#F8B195", "#C06C84"]
    return colors.randomElement() ?? "#4ECDC4"
  }
}

@Model
class StreakRecord {
  var date: Date // The date this streak activity occurred
  var activityType: String // "task", "exam", "pomodoro"
  var activityTitle: String // Title of the task/exam or "Pomodoro Session"
  var activityDetails: String // Additional details
  var completedAt: Date // When it was completed
  
  init(date: Date, activityType: String, activityTitle: String, activityDetails: String = "", completedAt: Date = Date()) {
    self.date = date
    self.activityType = activityType
    self.activityTitle = activityTitle
    self.activityDetails = activityDetails
    self.completedAt = completedAt
  }
}

@Model
class OtherEventRecord {
  var title: String
  var eventType: String // "Interview", "Code Chat", "Meeting", "Other"
  var customType: String // For "Other" type
  var details: String
  var mode: String // "In Person", "Online"
  var location: String // Room/building for in-person, link for online
  var date: Date
  var time: Date
  var durationMinutes: Int
  var colorHex: String
  
  init(title: String, eventType: String, customType: String = "", details: String = "", mode: String, location: String = "", date: Date, time: Date, durationMinutes: Int, colorHex: String = "") {
    self.title = title
    self.eventType = eventType
    self.customType = customType
    self.details = details
    self.mode = mode
    self.location = location
    self.date = date
    self.time = time
    self.durationMinutes = durationMinutes
    self.colorHex = colorHex.isEmpty ? Self.randomColor() : colorHex
  }
  
  static func randomColor() -> String {
    let colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2", "#F8B195", "#C06C84"]
    return colors.randomElement() ?? "#4ECDC4"
  }
}

