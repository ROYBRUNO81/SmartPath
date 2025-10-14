//
//  HomeView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/7/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @State private var refreshTrigger = false
    @State private var selectedFilter: EventFilter = .classes
    
    enum EventFilter {
        case classes, exams, tasks
    }
    
    var body: some View {
        ZStack {
            Color.spBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Top section with greeting and user info
                    topSection
                    
                    // Summary pills (filter tabs)
                    summaryPills
                    
                    // Daily schedule
                    dailySchedule
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.spSecondary)
                        .font(.title2)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshCalendar"))) { _ in
            refreshTrigger.toggle()
        }
    }
    
    private var topSection: some View {
        VStack(spacing: 8) {
            Text(greeting)
                .font(.title)
                .foregroundColor(Color.spSecondary)
            
            Text("John") // TODO: Get from user profile
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.spSecondary)
            
            Text(currentDateString)
                .font(.title3)
                .foregroundColor(Color.spSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var summaryPills: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Button(action: { selectedFilter = .classes }) {
                    SummaryPill(
                        count: classCount,
                        label: "Classes",
                        isHighlighted: selectedFilter == .classes
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: { selectedFilter = .exams }) {
                    SummaryPill(
                        count: examCount,
                        label: "Exams",
                        isHighlighted: selectedFilter == .exams
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: { selectedFilter = .tasks }) {
                    SummaryPill(
                        count: taskCount,
                        label: "Tasks Due",
                        isHighlighted: selectedFilter == .tasks
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Separator line
            Rectangle()
                .fill(Color.spSecondary.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 20)
        }
    }
    
    private var dailySchedule: some View {
        VStack(spacing: 16) {
            if filteredTodayEvents.isEmpty {
                Text("Nothing to show!")
                    .font(.title2)
                    .foregroundColor(Color.spSecondary.opacity(0.6))
                    .padding(.vertical, 40)
            } else {
                ForEach(filteredTodayEvents, id: \.id) { event in
                    ScheduleCard(event: event)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning!"
        case 12..<17: return "Good Afternoon!"
        case 17..<22: return "Good Evening!"
        default: return "Good Night!"
        }
    }
    
    private var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        return formatter.string(from: Date())
    }
    
    private var classCount: Int {
        guard let classes = try? context.fetch(FetchDescriptor<ClassRecord>()) else { return 0 }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        return classes.filter { classRec in
            classRec.startDate <= today && classRec.endDate >= today &&
            classRec.days.contains(where: { day in
                let weekdayFormatter = DateFormatter()
                weekdayFormatter.dateFormat = "EEE"
                let todayAbbr = weekdayFormatter.string(from: today).prefix(3)
                return day.prefix(3) == todayAbbr
            })
        }.count
    }
    
    private var examCount: Int {
        guard let exams = try? context.fetch(FetchDescriptor<ExamRecord>()) else { return 0 }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        return exams.filter { exam in
            if exam.isRepeating {
                if let start = exam.startDate, let end = exam.endDate {
                    let examStartDate = cal.startOfDay(for: start)
                    let examEndDate = cal.startOfDay(for: end)
                    let isInDateRange = today >= examStartDate && today <= examEndDate
                    let isScheduledDay = exam.days.contains(where: { day in
                        let weekdayFormatter = DateFormatter()
                        weekdayFormatter.dateFormat = "EEE"
                        let todayAbbr = weekdayFormatter.string(from: today).prefix(3)
                        return day.prefix(3) == todayAbbr
                    })
                    return isInDateRange && isScheduledDay
                }
                return false
            } else {
                let examDate = cal.startOfDay(for: exam.date)
                return examDate == today
            }
        }.count
    }
    
    private var taskCount: Int {
        guard let tasks = try? context.fetch(FetchDescriptor<TaskRecord>()) else { return 0 }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        return tasks.filter { task in
            if task.occurs == "Repeating" {
                if let start = task.startDate, let end = task.endDate {
                    let taskStartDate = cal.startOfDay(for: start)
                    let taskEndDate = cal.startOfDay(for: end)
                    let isInDateRange = today >= taskStartDate && today <= taskEndDate
                    let isScheduledDay = task.days.contains(where: { day in
                        let weekdayFormatter = DateFormatter()
                        weekdayFormatter.dateFormat = "EEE"
                        let todayAbbr = weekdayFormatter.string(from: today).prefix(3)
                        return day.prefix(3) == todayAbbr
                    })
                    return isInDateRange && isScheduledDay
                }
                return false
            } else {
                let taskDate = cal.startOfDay(for: task.dueDate)
                return taskDate == today
            }
        }.count
    }
    
    private var todayEvents: [TodayEvent] {
        var events: [TodayEvent] = []
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        // Get classes for today
        if let classes = try? context.fetch(FetchDescriptor<ClassRecord>()) {
            for classRec in classes {
                if classRec.startDate <= today && classRec.endDate >= today {
                    let weekdayFormatter = DateFormatter()
                    weekdayFormatter.dateFormat = "EEE"
                    let todayAbbr = weekdayFormatter.string(from: today).prefix(3)
                    
                    if classRec.days.contains(where: { $0.prefix(3) == todayAbbr }) {
                        events.append(TodayEvent(
                            id: "class-\(classRec.className)",
                            title: classRec.className.uppercased(),
                            subtitle: classRec.teacher,
                            time: "\(timeString(classRec.startTime)) - \(timeString(classRec.endTime))",
                            type: .classSession,
                            color: Color(hex: classRec.colorHex),
                            backgroundImage: backgroundImageForSubject(classRec.className),
                            isUpNext: events.isEmpty,
                            taskCount: 0 // TODO: Calculate tasks for this class
                        ))
                    }
                }
            }
        }
        
        // Get exams for today
        if let exams = try? context.fetch(FetchDescriptor<ExamRecord>()) {
            for exam in exams {
                var isToday = false
                
                if exam.isRepeating {
                    if let start = exam.startDate, let end = exam.endDate {
                        let examStartDate = cal.startOfDay(for: start)
                        let examEndDate = cal.startOfDay(for: end)
                        let isInDateRange = today >= examStartDate && today <= examEndDate
                        let isScheduledDay = exam.days.contains(where: { day in
                            let weekdayFormatter = DateFormatter()
                            weekdayFormatter.dateFormat = "EEE"
                            let todayAbbr = weekdayFormatter.string(from: today).prefix(3)
                            return day.prefix(3) == todayAbbr
                        })
                        isToday = isInDateRange && isScheduledDay
                    }
                } else {
                    let examDate = cal.startOfDay(for: exam.date)
                    isToday = examDate == today
                }
                
                if isToday {
                    events.append(TodayEvent(
                        id: "exam-\(exam.name)",
                        title: exam.name.uppercased(),
                        subtitle: exam.examType == "Other" ? exam.customType : exam.examType,
                        time: "\(timeString(exam.time)) - \(timeString(cal.date(byAdding: .minute, value: exam.durationMinutes, to: exam.time) ?? exam.time))",
                        type: .exam,
                        color: Color(hex: exam.colorHex),
                        backgroundImage: backgroundImageForSubject(exam.name),
                        isUpNext: events.isEmpty,
                        taskCount: 0
                    ))
                }
            }
        }
        
        // Get tasks for today
        if let tasks = try? context.fetch(FetchDescriptor<TaskRecord>()) {
            for task in tasks {
                var isToday = false
                
                if task.occurs == "Repeating" {
                    if let start = task.startDate, let end = task.endDate {
                        let taskStartDate = cal.startOfDay(for: start)
                        let taskEndDate = cal.startOfDay(for: end)
                        let isInDateRange = today >= taskStartDate && today <= taskEndDate
                        let isScheduledDay = task.days.contains(where: { day in
                            let weekdayFormatter = DateFormatter()
                            weekdayFormatter.dateFormat = "EEE"
                            let todayAbbr = weekdayFormatter.string(from: today).prefix(3)
                            return day.prefix(3) == todayAbbr
                        })
                        isToday = isInDateRange && isScheduledDay
                    }
                } else {
                    let taskDate = cal.startOfDay(for: task.dueDate)
                    isToday = taskDate == today
                }
                
                if isToday {
                    events.append(TodayEvent(
                        id: "task-\(task.title)",
                        title: task.title.uppercased(),
                        subtitle: task.details,
                        time: timeString(task.dueTime),
                        type: .exam, // Using exam type for tasks since we don't have a task type in EventType
                        color: Color(hex: task.colorHex),
                        backgroundImage: "📝",
                        isUpNext: events.isEmpty,
                        taskCount: 0
                    ))
                }
            }
        }
        
        // Sort by start time
        return events.sorted { event1, event2 in
            let time1 = extractTimeFromString(event1.time)
            let time2 = extractTimeFromString(event2.time)
            return time1 < time2
        }
    }
    
    private var filteredTodayEvents: [TodayEvent] {
        switch selectedFilter {
        case .classes:
            return todayEvents.filter { $0.type == .classSession }
        case .exams:
            return todayEvents.filter { $0.type == .exam }
        case .tasks:
            return todayEvents.filter { $0.backgroundImage == "📝" } // Tasks have 📝 emoji
        }
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func backgroundImageForSubject(_ subject: String) -> String {
        let lowercased = subject.lowercased()
        if lowercased.contains("chemistry") || lowercased.contains("chem") {
            return "🧪"
        } else if lowercased.contains("math") || lowercased.contains("calculus") || lowercased.contains("algebra") {
            return "📐"
        } else if lowercased.contains("history") || lowercased.contains("museum") {
            return "🏛️"
        } else if lowercased.contains("physics") {
            return "⚛️"
        } else if lowercased.contains("biology") || lowercased.contains("bio") {
            return "🧬"
        } else if lowercased.contains("computer") || lowercased.contains("programming") || lowercased.contains("cs") {
            return "💻"
        } else {
            return "📚"
        }
    }
    
    private func extractTimeFromString(_ timeString: String) -> Date {
        let components = timeString.components(separatedBy: " - ")
        if let firstTime = components.first {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.date(from: firstTime) ?? Date()
        }
        return Date()
    }
}

// MARK: - Supporting Views

struct SummaryPill: View {
    let count: Int
    let label: String
    let isHighlighted: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isHighlighted ? Color.spPrimary : Color.spPrimary.opacity(0.3))
        )
    }
}

struct ScheduleCard: View {
    let event: TodayEvent
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.spPrimary.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.spSecondary.opacity(0.1), radius: 4, x: 0, y: 2)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(event.color)
                        
                        Spacer()
                        
                        if event.isUpNext {
                            Text("Up Next")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.spPrimary)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(event.subtitle)
                        .font(.subheadline)
                        .foregroundColor(Color.spSecondary)
                    
                    Text(event.time)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.spSecondary)
                }
                
                Spacer()
                
                VStack {
                    Text(event.backgroundImage)
                        .font(.system(size: 60))
                        .opacity(0.3)
                    
                    if event.taskCount > 0 {
                        Button(action: {}) {
                            Text("\(event.taskCount) Task\(event.taskCount == 1 ? "" : "s") Due")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.spSecondary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Data Models

struct TodayEvent: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let time: String
    let type: EventType
    let color: Color
    let backgroundImage: String
    let isUpNext: Bool
    let taskCount: Int
}
