//
//  AddModels.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 10/12/25.
//

import SwiftData
import Foundation

@Model
class TaskRecord {
  var title: String
  var details: String
  var subject: String
  var occurs: String // "Once" or "Repeating"
  var dueDate: Date
  var dueTime: Date

  init(title: String, details: String, subject: String, occurs: String, dueDate: Date, dueTime: Date) {
    self.title = title
    self.details = details
    self.subject = subject
    self.occurs = occurs
    self.dueDate = dueDate
    self.dueTime = dueTime
  }
}

@Model
class ExamRecord {
  var name: String
  var subject: String
  var examType: String // Exam, Quiz, Test
  var mode: String // In Person, Online
  var seat: String
  var room: String
  var date: Date
  var time: Date
  var durationMinutes: Int

  init(name: String, subject: String, examType: String, mode: String, seat: String, room: String, date: Date, time: Date, durationMinutes: Int) {
    self.name = name
    self.subject = subject
    self.examType = examType
    self.mode = mode
    self.seat = seat
    self.room = room
    self.date = date
    self.time = time
    self.durationMinutes = durationMinutes
  }
}

@Model
class ClassRecord {
  var mode: String // In Person, Online
  var className: String
  var room: String
  var building: String
  var teacher: String
  var subject: String
  var occurs: String // Once, Repeating
  var days: [String] // Mon..Sun
  var startTime: Date
  var endTime: Date

  init(mode: String, className: String, room: String, building: String, teacher: String, subject: String, occurs: String, days: [String], startTime: Date, endTime: Date) {
    self.mode = mode
    self.className = className
    self.room = room
    self.building = building
    self.teacher = teacher
    self.subject = subject
    self.occurs = occurs
    self.days = days
    self.startTime = startTime
    self.endTime = endTime
  }
}

