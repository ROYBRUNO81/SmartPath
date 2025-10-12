//
//  EventItem.swift
//  SmartPath
//
//  Created by Assistant on 10/12/25.
//

import Foundation

enum EventType: String, CaseIterable, Codable, Identifiable {
    case classSession = "Class"
    case interview    = "Interview"
    case coffeeChat   = "Coffee chat"
    case campusEvent  = "Campus event"
    case exam         = "Exam"
    case holiday      = "Holiday"
    var id: String { rawValue }
}

struct EventItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var type: EventType
    var repeating: TaskRepeat

    init(id: UUID = UUID(), title: String, date: Date, startTime: Date, endTime: Date, type: EventType, repeating: TaskRepeat) {
        self.id = id
        self.title = title
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.type = type
        self.repeating = repeating
    }
}

extension EventItem {
    static func sampleData(reference: Date = Date()) -> [EventItem] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: reference)

        func time(on day: Date, _ hour: Int, _ min: Int) -> Date {
            var comps = cal.dateComponents([.year, .month, .day], from: day)
            comps.hour = hour
            comps.minute = min
            return cal.date(from: comps)!
        }

        let day1 = today
        let day2 = cal.date(byAdding: .day, value: 1, to: today)!
        let day3 = cal.date(byAdding: .day, value: 3, to: today)! // leave a gap for an empty day

        return [
            EventItem(title: "CIS 1951 Lecture", date: day1, startTime: time(on: day1, 10, 30), endTime: time(on: day1, 11, 45), type: .classSession, repeating: .everyWeek),
            EventItem(title: "Algorithms Recitation", date: day1, startTime: time(on: day1, 13, 0), endTime: time(on: day1, 13, 50), type: .classSession, repeating: .everyWeek),
            EventItem(title: "Internship Interview", date: day2, startTime: time(on: day2, 15, 0), endTime: time(on: day2, 15, 45), type: .interview, repeating: .once),
            EventItem(title: "Coffee chat with TA", date: day3, startTime: time(on: day3, 9, 30), endTime: time(on: day3, 10, 0), type: .coffeeChat, repeating: .once)
        ]
    }
}


