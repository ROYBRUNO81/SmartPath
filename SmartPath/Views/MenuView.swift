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
                            
                            NavigationLink(destination: OtherEventCategoryView(context: context)) {
                                StatCardButton(
                                    emoji: "🎯",
                                    title: "Other Events",
                                    count: getOtherEventCount(),
                                    subtitle: "Interviews & more",
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
        let now = Date()
        return tasks.filter { task in
            !task.isCompleted && task.dueDate >= now
        }.count
    }
    
    private func getClassCount() -> Int {
        guard let classes = try? context.fetch(FetchDescriptor<ClassRecord>()) else { return 0 }
        let now = Date()
        return classes.filter { classRec in
            classRec.endDate >= now
        }.count
    }
    
    private func getExamCount() -> Int {
        guard let exams = try? context.fetch(FetchDescriptor<ExamRecord>()) else { return 0 }
        let now = Date()
        return exams.filter { exam in
            exam.date >= now
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
    
    private func getOtherEventCount() -> Int {
        return (try? context.fetch(FetchDescriptor<OtherEventRecord>()))?.count ?? 0
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
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            SwipeableTabView(tabs: ["Current", "Past"], selectedIndex: $selectedTab) { index in
                if index == 0 {
                    CurrentClassView(context: context)
                } else {
                    PastClassView(context: context)
                }
            }
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
    @State private var daysShown = 7
    
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
            
            // Skip overdue tasks - they should only appear in past tasks
            if task.dueDate < now {
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
            
            // Include completed tasks OR overdue tasks (not completed)
            if shouldInclude && (task.isCompleted || task.dueDate < now) {
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
struct CurrentClassView: View {
    let context: ModelContext
    @State private var daysShown = 7
    
    private var grouped: [(date: Date, items: [ClassRecord])] {
        guard let allClasses = try? context.fetch(FetchDescriptor<ClassRecord>()) else { return [] }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: daysShown, to: start)!
        
        var dateMap: [Date: [ClassRecord]] = [:]
        
        for classRec in allClasses {
            if classRec.startDate <= end && classRec.endDate >= start {
                // Generate class occurrences for each day in the range
                var current = max(start, cal.startOfDay(for: classRec.startDate))
                let rangeEnd = min(end, cal.startOfDay(for: classRec.endDate))
                
                while current < rangeEnd {
                    let weekdayFormatter = DateFormatter()
                    weekdayFormatter.dateFormat = "EEE"
                    let dayAbbr = weekdayFormatter.string(from: current).prefix(3)
                    
                    if classRec.days.contains(where: { $0.prefix(3) == dayAbbr }) {
                        if dateMap[current] == nil { dateMap[current] = [] }
                        dateMap[current]?.append(classRec)
                    }
                    current = cal.date(byAdding: .day, value: 1, to: current) ?? current
                }
            }
        }
        
        return dateMap.map { (date: $0.key, items: $0.value.sorted { $0.startTime < $1.startTime }) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                    if grouped.isEmpty {
                        Text("No upcoming classes")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                            .padding()
                    } else {
                        ForEach(grouped, id: \.date) { bucket in
                            Section(header: header(bucket.date, count: bucket.items.count)) {
                                ForEach(bucket.items, id: \.self) { item in
                                    ClassRow(classRec: item)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Classes")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshMenuCounts"))) { _ in
            // Refresh the view when data changes
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

// MARK: - Past Class View
struct PastClassView: View {
    let context: ModelContext
    @State private var daysShown = 14
    
    var classes: [ClassRecord] {
        guard let allClasses = try? context.fetch(FetchDescriptor<ClassRecord>()) else { return [] }
        let cal = Calendar.current
        let now = cal.startOfDay(for: Date())
        let startDate = cal.date(byAdding: .day, value: -daysShown, to: now) ?? now
        
        return allClasses.filter { classRec in
            classRec.startDate < now && classRec.endDate >= startDate
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if classes.isEmpty {
                    Text("No past classes")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                        .padding()
                } else {
                    ForEach(classes) { classRec in
                        ClassRow(classRec: classRec)
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