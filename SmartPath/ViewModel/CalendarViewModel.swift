//
//  CalendarViewModel.swift
//  SmartPath
//
//  Created by Assistant on 10/12/25.
//

import Foundation
import SwiftUI

enum CalendarMode: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    var id: String { rawValue }
}

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var mode: CalendarMode = .day
    @Published var anchorDate: Date = Date()
    @Published var showMenu: Bool = false

    // Filters
    @Published var showTasks: Bool = true
    @Published var showClasses: Bool = true
    @Published var showExams: Bool = true
    @Published var showHolidays: Bool = true
    @Published var showInterviews: Bool = true
    @Published var showCoffeeChats: Bool = true

    private let calendar = Calendar.current

    func goToday() { anchorDate = Date() }
    func previous() {
        switch mode {
        case .day:   anchorDate = calendar.date(byAdding: .day, value: -1, to: anchorDate) ?? anchorDate
        case .week:  anchorDate = calendar.date(byAdding: .day, value: -7, to: anchorDate) ?? anchorDate
        case .month: anchorDate = calendar.date(byAdding: .month, value: -1, to: anchorDate) ?? anchorDate
        }
    }
    func next() {
        switch mode {
        case .day:   anchorDate = calendar.date(byAdding: .day, value: 1, to: anchorDate) ?? anchorDate
        case .week:  anchorDate = calendar.date(byAdding: .day, value: 7, to: anchorDate) ?? anchorDate
        case .month: anchorDate = calendar.date(byAdding: .month, value: 1, to: anchorDate) ?? anchorDate
        }
    }

    // Data sources (stubbed with sample data for now)
    var tasks: [TaskItem] { TaskItem.sampleData(reference: anchorDate) }
    var events: [EventItem] { EventItem.sampleData(reference: anchorDate) }

    // Filtering
    func visibleEvents(in range: DateInterval) -> [EventItem] {
        events.filter { evt in
            let date = calendar.startOfDay(for: evt.date)
            let includeType: Bool = {
                switch evt.type {
                case .classSession: return showClasses
                case .interview:    return showInterviews
                case .coffeeChat:   return showCoffeeChats
                case .campusEvent:  return showHolidays // treat campus events with holiday color toggle
                case .exam:         return showExams
                case .holiday:      return showHolidays
                }
            }()
            return includeType && range.contains(date)
        }
    }

    func visibleTasks(in range: DateInterval) -> [TaskItem] {
        guard showTasks else { return [] }
        return tasks.filter { t in
            range.contains(calendar.startOfDay(for: t.dueDate))
        }
    }
}


