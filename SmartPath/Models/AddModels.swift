//
//  AddModels.swift
//  SmartPath
//
//  Created by Assistant on 10/12/25.
//

import SwiftData
import Foundation

@Model
class TaskRecord {
  var title: String
  var details: String
  var subject: String
  var occursRepeating: Bool
  var dueDate: Date
  var dueTime: Date

  init(title: String, details: String, subject: String, occursRepeating: Bool, dueDate: Date, dueTime: Date) {
    self.title = title
    self.details = details
    self.subject = subject
    self.occursRepeating = occursRepeating
    self.dueDate = dueDate
    self.dueTime = dueTime
  }
}

@Model
class ExamRecord {
  var name: String
  var subject: String
  var type: String // Exam, Quiz, Test
  var modeInPerson: Bool
  var seat: String
  var room: String
  var date: Date
  var time: Date
  var durationMinutes: Int

  init(name: String, subject: String, type: String, modeInPerson: Bool, seat: String, room: String, date: Date, time: Date, durationMinutes: Int) {
    self.name = name
    self.subject = subject
    self.type = type
    self.modeInPerson = modeInPerson
    self.seat = seat
    self.room = room
    self.date = date
    self.time = time
    self.durationMinutes = durationMinutes
  }
}

@Model
class ClassRecord {
  var modeInPerson: Bool
  var className: String
  var room: String
  var building: String
  var teacher: String
  var subject: String
  var startDate: Date?
  var endDate: Date?
  var occursRepeating: Bool
  var daysOfWeek: [String]
  var startTime: Date
  var endTime: Date

  init(modeInPerson: Bool, className: String, room: String, building: String, teacher: String, subject: String, startDate: Date?, endDate: Date?, occursRepeating: Bool, daysOfWeek: [String], startTime: Date, endTime: Date) {
    self.modeInPerson = modeInPerson
    self.className = className
    self.room = room
    self.building = building
    self.teacher = teacher
    self.subject = subject
    self.startDate = startDate
    self.endDate = endDate
    self.occursRepeating = occursRepeating
    self.daysOfWeek = daysOfWeek
    self.startTime = startTime
    self.endTime = endTime
  }
}


