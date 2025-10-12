//
//  TaskItem.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 10/12/25.
//

import Foundation

enum TaskType: String, CaseIterable, Codable, Identifiable {
    case assignment = "Assignment"
    case reminder   = "Reminder"
    case essay      = "Essay"
    var id: String { rawValue }
}

enum TaskRepeat: String, CaseIterable, Codable, Identifiable {
    case once = "Once"
    case everyWeek = "Every week"
    var id: String { rawValue }
}

struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var type: TaskType
    var repeating: TaskRepeat
    var dueDate: Date // calendar date component matters
    var dueTime: Date // time component matters

    init(id: UUID = UUID(), title: String, description: String, type: TaskType, repeating: TaskRepeat, dueDate: Date, dueTime: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.repeating = repeating
        self.dueDate = dueDate
        self.dueTime = dueTime
    }
}

extension TaskItem {
    static func sampleData(reference: Date = Date()) -> [TaskItem] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: reference)
        let day1 = today
        let day2 = cal.date(byAdding: .day, value: 1, to: today)!
        let day3 = cal.date(byAdding: .day, value: 2, to: today)!

        func time(_ hour: Int, _ min: Int) -> Date {
            cal.date(bySettingHour: hour, minute: min, second: 0, of: today)!
        }

        return [
            TaskItem(title: "Math Problem Set 3", description: "Ch. 5 integrals 1-20", type: .assignment, repeating: .once, dueDate: day1, dueTime: time(23, 59)),
            TaskItem(title: "CS Lecture Review", description: "Summarize notes and flashcards", type: .reminder, repeating: .everyWeek, dueDate: day1, dueTime: time(18, 0)),
            TaskItem(title: "History Essay Draft", description: "500 words on sources", type: .essay, repeating: .once, dueDate: day2, dueTime: time(17, 0)),
            TaskItem(title: "Chemistry Quiz Prep", description: "Ch. 3-4 practice", type: .reminder, repeating: .once, dueDate: day2, dueTime: time(20, 0)),
            TaskItem(title: "Group Project Sync", description: "Update slides", type: .assignment, repeating: .everyWeek, dueDate: day3, dueTime: time(16, 30))
        ]
    }
}


