//
//  CalendarViewModel.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 10/12/25.
//

import Foundation
import SwiftUI
import SwiftData

enum CalendarMode: String, CaseIterable, Identifiable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    var id: String { rawValue }
}

// Unified model for displaying events on calendar
struct DisplayEvent: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let type: String // "Class", "Task", "Exam"
    let startTime: Date
    let endTime: Date
    let colorHex: String
    let originalRecord: Any // Can be TaskRecord, ClassRecord, or ExamRecord
}

// Model for handling overlapping events
struct EventGroup: Identifiable {
    let id = UUID()
    let events: [DisplayEvent]
    let startTime: Date
    let endTime: Date
    
    // Calculate layout properties for each event in the group
    func layoutProperties(for event: DisplayEvent, totalWidth: CGFloat) -> (x: CGFloat, width: CGFloat) {
        let eventIndex = events.firstIndex { $0.id == event.id } ?? 0
        let eventWidth = totalWidth / CGFloat(events.count)
        let x = CGFloat(eventIndex) * eventWidth
        return (x: x, width: eventWidth)
    }
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
    @Published var showOtherEvents: Bool = true
    @Published var showHolidays: Bool = true
    @Published var showInterviews: Bool = true
    @Published var showCoffeeChats: Bool = true

    private let calendar = Calendar.current
    private var context: ModelContext?
    
    func setContext(_ context: ModelContext) {
        self.context = context
    }

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

    // Fetch all events from database and convert to DisplayEvent
    func fetchDisplayEvents(for date: Date) -> [DisplayEvent] {
        guard let context = context else { return [] }
        
        var displayEvents: [DisplayEvent] = []
        let targetDate = calendar.startOfDay(for: date)
        
        // Fetch Tasks
        if showTasks, let tasks = try? context.fetch(FetchDescriptor<TaskRecord>()) {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            let dayAbbr = weekdayFormatter.string(from: date).prefix(3)
            
            for task in tasks {
                if task.occurs == "Repeating" {
                    // Repeating task - check date range and day of week
                    if let start = task.startDate, let end = task.endDate {
                        let taskStartDate = calendar.startOfDay(for: start)
                        let taskEndDate = calendar.startOfDay(for: end)
                        let isInDateRange = targetDate >= taskStartDate && targetDate <= taskEndDate
                        let isScheduledDay = task.days.contains(where: { $0.prefix(3) == dayAbbr })
                        
                        if isInDateRange && isScheduledDay {
                            displayEvents.append(DisplayEvent(
                                title: task.title,
                                subtitle: task.details,
                                type: "Task",
                                startTime: task.dueTime,
                                endTime: calendar.date(byAdding: .minute, value: 30, to: task.dueTime) ?? task.dueTime,
                                colorHex: task.colorHex,
                                originalRecord: task
                            ))
                        }
                    }
                } else {
                    // One-time task
                    let taskDate = calendar.startOfDay(for: task.dueDate)
                    if taskDate == targetDate {
                        displayEvents.append(DisplayEvent(
                            title: task.title,
                            subtitle: task.details,
                            type: "Task",
                            startTime: task.dueTime,
                            endTime: calendar.date(byAdding: .minute, value: 30, to: task.dueTime) ?? task.dueTime,
                            colorHex: task.colorHex,
                            originalRecord: task
                        ))
                    }
                }
            }
        }
        
        // Fetch Exams
        if showExams, let exams = try? context.fetch(FetchDescriptor<ExamRecord>()) {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            let dayAbbr = weekdayFormatter.string(from: date).prefix(3)
            
            for exam in exams {
                if exam.isRepeating {
                    // Repeating quiz - check date range and day of week
                    if let start = exam.startDate, let end = exam.endDate {
                        let examStartDate = calendar.startOfDay(for: start)
                        let examEndDate = calendar.startOfDay(for: end)
                        let isInDateRange = targetDate >= examStartDate && targetDate <= examEndDate
                        let isScheduledDay = exam.days.contains(where: { $0.prefix(3) == dayAbbr })
                        
                        if isInDateRange && isScheduledDay {
                            let displayType = exam.examType == "Other" ? exam.customType : exam.examType
                            displayEvents.append(DisplayEvent(
                                title: exam.name,
                                subtitle: displayType,
                                type: "Exam",
                                startTime: exam.time,
                                endTime: calendar.date(byAdding: .minute, value: exam.durationMinutes, to: exam.time) ?? exam.time,
                                colorHex: exam.colorHex,
                                originalRecord: exam
                            ))
                        }
                    }
                } else {
                    // One-time exam
                    let examDate = calendar.startOfDay(for: exam.date)
                    if examDate == targetDate {
                        let displayType = exam.examType == "Other" ? exam.customType : exam.examType
                        displayEvents.append(DisplayEvent(
                            title: exam.name,
                            subtitle: displayType,
                            type: "Exam",
                            startTime: exam.time,
                            endTime: calendar.date(byAdding: .minute, value: exam.durationMinutes, to: exam.time) ?? exam.time,
                            colorHex: exam.colorHex,
                            originalRecord: exam
                        ))
                    }
                }
            }
        }
        
        // Fetch Classes
        if showClasses, let classes = try? context.fetch(FetchDescriptor<ClassRecord>()) {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE" // "Mon", "Tue", etc.
            let dayAbbr = weekdayFormatter.string(from: date).prefix(3)
            
            for classRec in classes {
                // Check if date is within the class date range
                let classStartDate = calendar.startOfDay(for: classRec.startDate)
                let classEndDate = calendar.startOfDay(for: classRec.endDate)
                
                let isInDateRange = targetDate >= classStartDate && targetDate <= classEndDate
                let isScheduledDay = classRec.days.contains(where: { $0.prefix(3) == dayAbbr })
                
                if isInDateRange && isScheduledDay {
                    displayEvents.append(DisplayEvent(
                        title: classRec.className,
                        subtitle: classRec.teacher,
                        type: "Class",
                        startTime: classRec.startTime,
                        endTime: classRec.endTime,
                        colorHex: classRec.colorHex,
                        originalRecord: classRec
                    ))
                }
            }
        }
        
        // Fetch Other Events
        if showOtherEvents, let otherEvents = try? context.fetch(FetchDescriptor<OtherEventRecord>()) {
            for otherEvent in otherEvents {
                let eventDate = calendar.startOfDay(for: otherEvent.date)
                if eventDate == targetDate {
                    let displayType = otherEvent.eventType == "Other" ? otherEvent.customType : otherEvent.eventType
                    displayEvents.append(DisplayEvent(
                        title: otherEvent.title,
                        subtitle: displayType,
                        type: "Other",
                        startTime: otherEvent.time,
                        endTime: calendar.date(byAdding: .minute, value: otherEvent.durationMinutes, to: otherEvent.time) ?? otherEvent.time,
                        colorHex: otherEvent.colorHex,
                        originalRecord: otherEvent
                    ))
                }
            }
        }
        
        return displayEvents.sorted { $0.startTime < $1.startTime }
    }
    
    // Group overlapping events together
    func groupOverlappingEvents(_ events: [DisplayEvent]) -> [EventGroup] {
        guard !events.isEmpty else { return [] }
        
        let sortedEvents = events.sorted { $0.startTime < $1.startTime }
        var groups: [EventGroup] = []
        var currentGroup: [DisplayEvent] = []
        var groupEndTime: Date = Date.distantPast
        
        for event in sortedEvents {
            // Check if this event overlaps with the current group
            // Events overlap if one starts before the other ends
            if event.startTime < groupEndTime {
                // Event overlaps, add to current group
                currentGroup.append(event)
                // Update group end time to the latest end time
                groupEndTime = max(groupEndTime, event.endTime)
            } else {
                // No overlap, finalize current group and start new one
                if !currentGroup.isEmpty {
                    let groupStartTime = currentGroup.first!.startTime
                    groups.append(EventGroup(
                        events: currentGroup,
                        startTime: groupStartTime,
                        endTime: groupEndTime
                    ))
                }
                
                // Start new group
                currentGroup = [event]
                groupEndTime = event.endTime
            }
        }
        
        // Don't forget the last group
        if !currentGroup.isEmpty {
            let groupStartTime = currentGroup.first!.startTime
            groups.append(EventGroup(
                events: currentGroup,
                startTime: groupStartTime,
                endTime: groupEndTime
            ))
        }
        
        return groups
    }

    // Old data sources for compatibility
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
                case .campusEvent:  return showHolidays
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


