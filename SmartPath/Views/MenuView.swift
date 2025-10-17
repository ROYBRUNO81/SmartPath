//
//  MenuView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/11/25.
//

import SwiftUI
import SwiftData

struct MenuView: View {
    @Environment(\.modelContext) private var context
    @State private var refreshTrigger = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Category Cards
                        HStack(spacing: 12) {
                            NavigationLink(destination: TaskCategoryView(context: context)) {
                                StatCardButton(
                                    emoji: "📝",
                                    title: "Tasks",
                                    count: getTaskCount(),
                                    subtitle: "All tasks",
                                    gradientColors: [
                                        Color.spPrimary.opacity(0.15),
                                        Color.white.opacity(0.7)
                                    ],
                                    countColor: Color.spPrimary
                                )
                            }
                            
                            NavigationLink(destination: ClassCategoryView(context: context)) {
                                StatCardButton(
                                    emoji: "🎓",
                                    title: "Classes",
                                    count: getClassCount(),
                                    subtitle: "All classes",
                                    gradientColors: [
                                        Color.spSecondary.opacity(0.15),
                                        Color.white.opacity(0.7)
                                    ],
                                    countColor: Color.spSecondary
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            NavigationLink(destination: ExamCategoryView(context: context)) {
                                StatCardButton(
                                    emoji: "📋",
                                    title: "Exams",
                                    count: getExamCount(),
                                    subtitle: "All exams",
                                    gradientColors: [
                                        Color.orange.opacity(0.15),
                                        Color.white.opacity(0.7)
                                    ],
                                    countColor: Color.orange
                                )
                            }
                            
                            NavigationLink(destination: OtherEventCategoryView(context: context)) {
                                StatCardButton(
                                    emoji: "📅",
                                    title: "Other Events",
                                    count: getOtherEventCount(),
                                    subtitle: "All events",
                                    gradientColors: [
                                        Color.blue.opacity(0.15),
                                        Color.white.opacity(0.7)
                                    ],
                                    countColor: Color.blue
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            NavigationLink(destination: TimerView()) {
                                StatCardButton(
                                    emoji: "⏳",
                                    title: "Focus Timer",
                                    count: 0,
                                    subtitle: "Pomodoro",
                                    gradientColors: [
                                        Color.spPrimary.opacity(0.15),
                                        Color.white.opacity(0.7)
                                    ],
                                    countColor: Color.spPrimary
                                )
                            }
                        }
                        .padding(.horizontal)

                        HStack(spacing: 12) {
                            NavigationLink(destination: StreakView()) {
                                StatCardButton(
                                    emoji: "🔥",
                                    title: "Study Streak",
                                    count: getCurrentStreak(),
                                    subtitle: "Keep it up!",
                                    gradientColors: [
                                        Color.orange.opacity(0.15),
                                        Color.white.opacity(0.7)
                                    ],
                                    countColor: Color.orange
                                )
                            }
                            
                            NavigationLink(destination: StreakView()) {
                                StatCardButton(
                                    emoji: "📊",
                                    title: "Statistics",
                                    count: 0,
                                    subtitle: "View progress",
                                    gradientColors: [
                                        Color.purple.opacity(0.15),
                                        Color.white.opacity(0.7)
                                    ],
                                    countColor: Color.purple
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshMenuCounts"))) { _ in
            refreshTrigger.toggle()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshStreak"))) { _ in
            refreshTrigger.toggle()
        }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshCalendar"))) { _ in
                refreshTrigger.toggle()
            }
        }
    }
    
    private func getTaskCount() -> Int {
        guard let tasks = try? context.fetch(FetchDescriptor<TaskRecord>()) else { return 0 }
        let cal = Calendar.current
        let now = Date()
        let today = cal.startOfDay(for: now)
        let endDate = cal.date(byAdding: .day, value: 14, to: today)!
        
        return tasks.filter { task in
            // Skip completed tasks
            if task.isCompleted {
                return false
            }
            
            if task.occurs == "Repeating" {
                // For repeating tasks, check if they have any occurrences in the next 14 days
                if let start = task.startDate, let end = task.endDate {
                    let taskStartDate = cal.startOfDay(for: start)
                    let taskEndDate = cal.startOfDay(for: end)
                    let isInDateRange = today <= taskEndDate && endDate >= taskStartDate
                    
                    if isInDateRange {
                        // Check if any of the scheduled days fall within the next 14 days
                        var current = max(today, taskStartDate)
                        let rangeEnd = min(endDate, taskEndDate)
                        
                        while current <= rangeEnd {
                            let weekdayFormatter = DateFormatter()
                            weekdayFormatter.dateFormat = "EEE"
                            let dayAbbr = weekdayFormatter.string(from: current).prefix(3)
                            
                            if task.days.contains(where: { $0.prefix(3) == dayAbbr }) {
                                return true
                            }
                            current = cal.date(byAdding: .day, value: 1, to: current) ?? current
                        }
                    }
                }
                return false
            } else {
                // For one-time tasks, check if due date is within next 14 days
                let taskDate = cal.startOfDay(for: task.dueDate)
                return taskDate >= today && taskDate <= endDate
            }
        }.count
    }
    
    private func getClassCount() -> Int {
        guard let classes = try? context.fetch(FetchDescriptor<ClassRecord>()) else { return 0 }
        let cal = Calendar.current
        let now = Date()
        
        // Get current week start (Monday)
        let currentWeekStart = cal.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekDays = (0..<7).compactMap { dayOffset in
            cal.date(byAdding: .day, value: dayOffset, to: currentWeekStart)
        }
        
        var totalCount = 0
        
        for classRec in classes {
            // Only include classes that haven't ended yet
            if classRec.endDate < now {
                continue
            }
            
            for day in weekDays {
                // Check if this class occurs on this day of the week
                let weekdayFormatter = DateFormatter()
                weekdayFormatter.dateFormat = "EEE"
                let dayAbbr = weekdayFormatter.string(from: day).prefix(3)
                
                if classRec.days.contains(where: { $0.prefix(3) == dayAbbr }) {
                    // Check if the class is active on this specific date
                    if classRec.startDate <= day && classRec.endDate >= day {
                        totalCount += 1
                    }
                }
            }
        }
        
        return totalCount
    }
    
    private func getExamCount() -> Int {
        guard let exams = try? context.fetch(FetchDescriptor<ExamRecord>()) else { return 0 }
        let now = Date()
        return exams.filter { exam in
            exam.date >= now
        }.count
    }
    
    private func getOtherEventCount() -> Int {
        guard let otherEvents = try? context.fetch(FetchDescriptor<OtherEventRecord>()) else { return 0 }
        let now = Date()
        return otherEvents.filter { event in
            event.date >= now
        }.count
    }
    
    private func getCurrentStreak() -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Get all unique dates with activities
        let allActivities = (try? context.fetch(FetchDescriptor<StreakRecord>())) ?? []
        let uniqueDates = Set(allActivities.map { cal.startOfDay(for: $0.date) }).sorted(by: >)
        
        // Count consecutive days from today backwards
        for date in uniqueDates {
            if cal.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = cal.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
}

// MARK: - Swipeable Tab System
struct SwipeableTabView<Content: View>: View {
    let tabs: [String]
    @Binding var selectedIndex: Int
    @ViewBuilder let content: (Int) -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Headers
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                    VStack(spacing: 8) {
                        Text(tab)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(selectedIndex == index ? .black : .black.opacity(0.5))
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(height: 3)
                            .opacity(selectedIndex == index ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Content with swipe gesture
            TabView(selection: $selectedIndex) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, _ in
                    content(index)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: selectedIndex)
        }
    }
}

// MARK: - Task Category View
struct TaskCategoryView: View {
    let context: ModelContext
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            SwipeableTabView(tabs: ["Current", "Past"], selectedIndex: $selectedTab) { index in
                if index == 0 {
                    CurrentTaskView(context: context)
                } else {
                    PastTaskView(context: context)
                }
            }
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
    }
}

// MARK: - Class Category View
struct ClassCategoryView: View {
    let context: ModelContext
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            WeeklyClassView(context: context)
        }
        .navigationTitle("Classes")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
    }
}

// MARK: - Exam Category View
struct ExamCategoryView: View {
    let context: ModelContext
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            SwipeableTabView(tabs: ["Current", "Past"], selectedIndex: $selectedTab) { index in
                if index == 0 {
                    CurrentExamView(context: context)
                } else {
                    PastExamView(context: context)
                }
            }
        }
        .navigationTitle("Exams")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
    }
}

// MARK: - Holiday Category View
struct HolidayCategoryView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            SwipeableTabView(tabs: ["Current", "Past"], selectedIndex: $selectedTab) { index in
                if index == 0 {
                    CurrentHolidayView()
                } else {
                    PastHolidayView()
                }
            }
        }
        .navigationTitle("Holidays")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
    }
}

// MARK: - Current Task View
struct CurrentTaskView: View {
    let context: ModelContext
    @State private var daysShown = 14
    @State private var refreshTrigger = false
    
    private var grouped: [(date: Date, items: [TaskRecord])] {
        guard let tasks = try? context.fetch(FetchDescriptor<TaskRecord>()) else { return [] }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: daysShown, to: start)!
        let now = Date()
        
        var dateMap: [Date: [TaskRecord]] = [:]
        
        for task in tasks {
            // Skip completed tasks - they should only appear in past tasks
            if task.isCompleted {
                continue
            }
            
            if task.occurs == "Repeating" {
                if let startDate = task.startDate, let endDate = task.endDate {
                    var current = max(start, cal.startOfDay(for: startDate))
                    let rangeEnd = min(end, cal.startOfDay(for: endDate))
                    
                    while current < rangeEnd {
                        let weekdayFormatter = DateFormatter()
                        weekdayFormatter.dateFormat = "EEE"
                        let dayAbbr = weekdayFormatter.string(from: current).prefix(3)
                        
                        if task.days.contains(where: { $0.prefix(3) == dayAbbr }) {
                            if dateMap[current] == nil { dateMap[current] = [] }
                            dateMap[current]?.append(task)
                        }
                        current = cal.date(byAdding: .day, value: 1, to: current) ?? current
                    }
                }
            } else {
                let taskDate = cal.startOfDay(for: task.dueDate)
                if taskDate >= start && taskDate < end {
                    if dateMap[taskDate] == nil { dateMap[taskDate] = [] }
                    dateMap[taskDate]?.append(task)
                }
            }
        }
        
        return dateMap.map { (date: $0.key, items: $0.value.sorted { $0.dueTime < $1.dueTime }) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                    if grouped.isEmpty {
                        Text("No upcoming tasks")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                            .padding()
                    } else {
                        ForEach(grouped, id: \.date) { bucket in
                            Section(header: header(bucket.date, count: bucket.items.count)) {
                                ForEach(bucket.items, id: \.self) { item in
                                    TaskRow(task: item)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .id(refreshTrigger) // Force refresh when trigger changes
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshMenuCounts"))) { _ in
            // Refresh the view when tasks are completed
        }
    }
    
    private func header(_ date: Date, count: Int) -> some View {
        HStack {
            Text(date, style: .date)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Text("\(count)")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.6))
                .clipShape(Capsule())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(BlurView(style: .systemMaterial))
    }
}

// MARK: - Past Task View
struct PastTaskView: View {
    let context: ModelContext
    @State private var daysShown = 14
    
    private var allTasks: [TaskRecord] {
        (try? context.fetch(FetchDescriptor<TaskRecord>())) ?? []
    }
    
    private var dateRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let now = cal.startOfDay(for: Date())
        let startDate = cal.date(byAdding: .day, value: -daysShown, to: now) ?? now
        return (start: startDate, end: now)
    }
    
    private var grouped: [(date: Date, items: [TaskRecord])] {
        let range = dateRange
        let now = Date()
        var dateMap: [Date: [TaskRecord]] = [:]
        
        for task in allTasks {
            var shouldInclude = false
            var taskDate = range.end // Default date for sorting
            
            if task.occurs == "Repeating" {
                if let start = task.startDate, let end = task.endDate, start <= range.end && end >= range.start {
                    shouldInclude = true
                    taskDate = range.end
                }
            } else {
                let dueDate = Calendar.current.startOfDay(for: task.dueDate)
                if dueDate >= range.start && dueDate < range.end {
                    shouldInclude = true
                    taskDate = dueDate
                }
            }
            
            // For completed tasks, only show if they are actually past (14+ days old)
            if task.isCompleted {
                let daysSinceCompletion = Calendar.current.dateComponents([.day], from: task.dueDate, to: now).day ?? 0
                if daysSinceCompletion >= 14 {
                    if task.occurs == "Repeating" {
                        if let start = task.startDate, let end = task.endDate, start <= range.end && end >= range.start {
                            shouldInclude = true
                            taskDate = range.end
                        }
                    } else {
                        let dueDate = Calendar.current.startOfDay(for: task.dueDate)
                        if dueDate >= range.start && dueDate < range.end {
                            shouldInclude = true
                            taskDate = dueDate
                        }
                    }
                }
            } else {
                // For incomplete tasks, only show if they are overdue
                if task.dueDate < now {
                    if task.occurs == "Repeating" {
                        if let start = task.startDate, let end = task.endDate, start <= range.end && end >= range.start {
                            shouldInclude = true
                            taskDate = range.end
                        }
                    } else {
                        let dueDate = Calendar.current.startOfDay(for: task.dueDate)
                        if dueDate >= range.start && dueDate < range.end {
                            shouldInclude = true
                            taskDate = dueDate
                        }
                    }
                }
            }
            
            if shouldInclude {
                if dateMap[taskDate] == nil { dateMap[taskDate] = [] }
                dateMap[taskDate]?.append(task)
            }
        }
        
        return dateMap.map { (date: $0.key, items: $0.value.sorted { $0.dueTime < $1.dueTime }) }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                    if grouped.isEmpty {
                        Text("No past tasks")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                            .padding()
                    } else {
                        ForEach(grouped, id: \.date) { bucket in
                            Section(header: header(bucket.date, count: bucket.items.count)) {
                                ForEach(bucket.items, id: \.self) { item in
                                    TaskRow(task: item, isInPastView: true)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Past Tasks")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshMenuCounts"))) { _ in
            // Refresh the view when tasks are completed
        }
    }
    
    private func header(_ date: Date, count: Int) -> some View {
        HStack {
            Text(date, style: .date)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Text("\(count)")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.6))
                .clipShape(Capsule())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(BlurView(style: .systemMaterial))
    }
    
    var canShowMore: Bool {
        return daysShown < 98
    }
    
    func showMore() {
        if daysShown == 14 { daysShown = 28 }
        else if daysShown == 28 { daysShown = 56 }
        else if daysShown == 56 { daysShown = 98 }
    }
}

// MARK: - Current Class View
// MARK: - Weekly Class View
struct WeeklyClassView: View {
    let context: ModelContext
    @State private var refreshTrigger = false
    @State private var currentWeekStart = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
    
    private var weekDays: [Date] {
        let cal = Calendar.current
        return (0..<7).compactMap { dayOffset in
            cal.date(byAdding: .day, value: dayOffset, to: currentWeekStart)
        }
    }
    
    private var weeklySchedule: [(day: Date, classes: [ClassRecord])] {
        guard let allClasses = try? context.fetch(FetchDescriptor<ClassRecord>()) else { return [] }
        let cal = Calendar.current
        let now = Date()
        
        return weekDays.map { day in
            let dayStart = cal.startOfDay(for: day)
            let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart)!
            
            let classesForDay = allClasses.compactMap { classRec -> ClassRecord? in
                // Only include classes that haven't ended yet
                if classRec.endDate < now {
                    return nil
                }
                
                // Check if this class occurs on this day of the week
                let weekdayFormatter = DateFormatter()
                weekdayFormatter.dateFormat = "EEE"
                let dayAbbr = weekdayFormatter.string(from: day).prefix(3)
                
                if classRec.days.contains(where: { $0.prefix(3) == dayAbbr }) {
                    // Check if the class is active on this specific date
                    if classRec.startDate <= day && classRec.endDate >= day {
                        return classRec
                    }
                }
                return nil
            }
            
            return (day: day, classes: classesForDay.sorted { $0.startTime < $1.startTime })
        }
    }
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Week navigation
                    weekNavigationHeader
                    
                    // Weekly schedule
                    LazyVStack(spacing: 12) {
                        ForEach(weeklySchedule, id: \.day) { dayData in
                            WeeklyDayRow(day: dayData.day, classes: dayData.classes)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshMenuCounts"))) { _ in
            refreshTrigger.toggle()
        }
    }
    
    private var weekNavigationHeader: some View {
        HStack {
            Button(action: { previousWeek() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(Color.spPrimary)
            }
            
            Spacer()
            
            Text(weekRangeText)
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { nextWeek() }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(Color.spPrimary)
            }
        }
        .padding(.horizontal)
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startDate = weekDays.first!
        let endDate = weekDays.last!
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    private func previousWeek() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) ?? currentWeekStart
        }
    }
    
    private func nextWeek() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) ?? currentWeekStart
        }
    }
}

// MARK: - Weekly Day Row
struct WeeklyDayRow: View {
    let day: Date
    let classes: [ClassRecord]
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day)
    }
    
    private var isToday: Bool {
        Calendar.current.isDate(day, inSameDayAs: Date())
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Day info
            VStack(spacing: 4) {
                Text(dayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.7))
                
                Text(dayNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isToday ? .white : .black)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(isToday ? Color.spPrimary : Color.clear)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.spPrimary, lineWidth: isToday ? 0 : 2)
                    )
            }
            .frame(width: 60)
            
            // Class count
            Text("\(classes.count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(width: 40)
            
            // Classes list
            if classes.isEmpty {
                Text("No classes")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(classes, id: \.self) { classRec in
                        HStack {
                            Circle()
                                .fill(Color(hex: classRec.colorHex))
                                .frame(width: 8, height: 8)
                            
                            Text(classRec.className)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text(timeString(classRec.startTime))
                                .font(.caption)
                                .foregroundColor(.black.opacity(0.6))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.spPrimary.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.spSecondary.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}


// MARK: - Current Exam View
struct CurrentExamView: View {
    let context: ModelContext
    @State private var daysShown = 7
    
    private var grouped: [(date: Date, items: [ExamRecord])] {
        guard let allExams = try? context.fetch(FetchDescriptor<ExamRecord>()) else { return [] }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: daysShown, to: start)!
        
        var dateMap: [Date: [ExamRecord]] = [:]
        
        for exam in allExams {
            if exam.isRepeating {
                if let startDate = exam.startDate, let endDate = exam.endDate {
                    var current = max(start, cal.startOfDay(for: startDate))
                    let rangeEnd = min(end, cal.startOfDay(for: endDate))
                    
                    while current < rangeEnd {
                        let weekdayFormatter = DateFormatter()
                        weekdayFormatter.dateFormat = "EEE"
                        let dayAbbr = weekdayFormatter.string(from: current).prefix(3)
                        
                        if exam.days.contains(where: { $0.prefix(3) == dayAbbr }) {
                            if dateMap[current] == nil { dateMap[current] = [] }
                            dateMap[current]?.append(exam)
                        }
                        current = cal.date(byAdding: .day, value: 1, to: current) ?? current
                    }
                }
            } else {
                let examDate = cal.startOfDay(for: exam.date)
                if examDate >= start && examDate < end {
                    if dateMap[examDate] == nil { dateMap[examDate] = [] }
                    dateMap[examDate]?.append(exam)
                }
            }
        }
        
        return dateMap.map { (date: $0.key, items: $0.value.sorted { $0.time < $1.time }) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                    if grouped.isEmpty {
                        Text("No upcoming exams")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                            .padding()
                    } else {
                        ForEach(grouped, id: \.date) { bucket in
                            Section(header: header(bucket.date, count: bucket.items.count)) {
                                ForEach(bucket.items, id: \.self) { item in
                                    ExamRow(exam: item)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Exams")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
    }
    
    private func header(_ date: Date, count: Int) -> some View {
        HStack {
            Text(date, style: .date)
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Text("\(count)")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.6))
                .clipShape(Capsule())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(BlurView(style: .systemMaterial))
    }
}

// MARK: - Past Exam View
struct PastExamView: View {
    let context: ModelContext
    @State private var daysShown = 14
    
    private var allExams: [ExamRecord] {
        (try? context.fetch(FetchDescriptor<ExamRecord>())) ?? []
    }
    
    private var dateRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let now = cal.startOfDay(for: Date())
        let startDate = cal.date(byAdding: .day, value: -daysShown, to: now) ?? now
        return (start: startDate, end: now)
    }
    
    var exams: [ExamRecord] {
        let range = dateRange
        var filtered: [(date: Date, exam: ExamRecord)] = []
        
        for exam in allExams {
            if exam.isRepeating {
                if let start = exam.startDate, let end = exam.endDate, start <= range.end && end >= range.start {
                    filtered.append((date: range.end, exam: exam))
                }
            } else {
                let examDate = Calendar.current.startOfDay(for: exam.date)
                if examDate >= range.start && examDate < range.end {
                    filtered.append((date: examDate, exam: exam))
                }
            }
        }
        
        return filtered.sorted { $0.date > $1.date }.map { $0.exam }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if exams.isEmpty {
                    Text("No past exams")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                        .padding()
                } else {
                    ForEach(exams) { exam in
                        ExamRow(exam: exam)
                            .padding(.horizontal)
                    }
                }
                
                if canShowMore {
                    Button(action: { showMore() }) {
                        Text("Show More")
                            .font(.subheadline)
                            .foregroundColor(Color.spPrimary)
                            .padding()
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    var canShowMore: Bool {
        return daysShown < 98
    }
    
    func showMore() {
        if daysShown == 14 { daysShown = 28 }
        else if daysShown == 28 { daysShown = 56 }
        else if daysShown == 56 { daysShown = 98 }
    }
}

// MARK: - Holiday Views
struct CurrentHolidayView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("No upcoming holidays")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
                    .padding()
            }
            .padding(.vertical)
        }
    }
}

struct PastHolidayView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("No past holidays")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
                    .padding()
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Row Views
struct TaskRow: View {
    let task: TaskRecord
    let isInPastView: Bool
    
    init(task: TaskRecord, isInPastView: Bool = false) {
        self.task = task
        self.isInPastView = isInPastView
    }
    
    var body: some View {
        if isInPastView {
            // Past task - show status but no interaction
            HStack {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(task.isCompleted ? .green : .red)
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                        .strikethrough(task.isCompleted)
                    
                    Text(task.details)
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.5))
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(task.isCompleted ? "Completed" : "Not Completed")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(task.isCompleted ? .green : .red)
                    Text(timeString(task.dueTime))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black.opacity(0.5))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                LinearGradient(
                    colors: task.isCompleted ? 
                        [Color.green.opacity(0.1), Color.green.opacity(0.05)] :
                        [Color.red.opacity(0.1), Color.red.opacity(0.05)], 
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14).stroke(
                    task.isCompleted ? Color.green.opacity(0.3) : Color.red.opacity(0.3), 
                    lineWidth: 1
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        } else {
            // Current task - navigable
            NavigationLink(destination: TaskDetailView(task: task)) {
                HStack {
                    Circle()
                        .fill(Color(hex: task.colorHex))
                        .frame(width: 8, height: 8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                        
                        Text(task.details)
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.6))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Text(timeString(task.dueTime))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black.opacity(0.7))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    LinearGradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

struct ClassRow: View {
    let classRec: ClassRecord
    
    var body: some View {
        NavigationLink(destination: ClassDetailView(classRecord: classRec)) {
            HStack {
                Circle()
                    .fill(Color(hex: classRec.colorHex))
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(classRec.className)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(classRec.teacher)
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.6))
                }
                
                Spacer()
                
                Text(timeString(classRec.startTime))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                LinearGradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
    
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

struct ExamRow: View {
    let exam: ExamRecord
    
    var body: some View {
        NavigationLink(destination: ExamDetailView(exam: exam)) {
            HStack {
                Circle()
                    .fill(Color(hex: exam.colorHex))
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(exam.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(exam.examType == "Other" ? exam.customType : exam.examType)
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.6))
                }
                
                Spacer()
                
                Text(timeString(exam.time))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                LinearGradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)], startPoint: .top, endPoint: .bottom)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
    
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}