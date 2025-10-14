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
                            
                            NavigationLink(destination: HolidayCategoryView()) {
                                StatCardButton(
                                    emoji: "🎉",
                                    title: "Holidays",
                                    count: 0,
                                    subtitle: "All holidays",
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshCalendar"))) { _ in
                refreshTrigger.toggle()
            }
        }
    }
    
    private func getTaskCount() -> Int {
        guard let tasks = try? context.fetch(FetchDescriptor<TaskRecord>()) else { return 0 }
        return tasks.count
    }
    
    private func getClassCount() -> Int {
        guard let classes = try? context.fetch(FetchDescriptor<ClassRecord>()) else { return 0 }
        return classes.count
    }
    
    private func getExamCount() -> Int {
        guard let exams = try? context.fetch(FetchDescriptor<ExamRecord>()) else { return 0 }
        return exams.count
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
    @State private var daysShown = 14
    
    private var allTasks: [TaskRecord] {
        (try? context.fetch(FetchDescriptor<TaskRecord>())) ?? []
    }
    
    private var dateRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let now = cal.startOfDay(for: Date())
        let endDate = cal.date(byAdding: .day, value: daysShown, to: now) ?? now
        return (start: now, end: endDate)
    }
    
    var tasks: [TaskRecord] {
        let range = dateRange
        var filtered: [(date: Date, task: TaskRecord)] = []
        
        for task in allTasks {
            if task.occurs == "Repeating" {
                if let start = task.startDate, let end = task.endDate, start <= range.end && end >= range.start {
                    filtered.append((date: range.start, task: task))
                }
            } else {
                let taskDate = Calendar.current.startOfDay(for: task.dueDate)
                if taskDate >= range.start && taskDate <= range.end {
                    filtered.append((date: taskDate, task: task))
                }
            }
        }
        
        return filtered.sorted { $0.date < $1.date }.map { $0.task }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if tasks.isEmpty {
                    Text("No upcoming tasks")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                        .padding()
                } else {
                    ForEach(tasks) { task in
                        TaskRow(task: task)
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
    
    var tasks: [TaskRecord] {
        let range = dateRange
        var filtered: [(date: Date, task: TaskRecord)] = []
        
        for task in allTasks {
            if task.occurs == "Repeating" {
                if let start = task.startDate, let end = task.endDate, start <= range.end && end >= range.start {
                    filtered.append((date: range.end, task: task))
                }
            } else {
                let taskDate = Calendar.current.startOfDay(for: task.dueDate)
                if taskDate >= range.start && taskDate < range.end {
                    filtered.append((date: taskDate, task: task))
                }
            }
        }
        
        return filtered.sorted { $0.date > $1.date }.map { $0.task }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if tasks.isEmpty {
                    Text("No past tasks")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                        .padding()
                } else {
                    ForEach(tasks) { task in
                        TaskRow(task: task)
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

// MARK: - Current Class View
struct CurrentClassView: View {
    let context: ModelContext
    @State private var daysShown = 14
    
    var classes: [ClassRecord] {
        guard let allClasses = try? context.fetch(FetchDescriptor<ClassRecord>()) else { return [] }
        let cal = Calendar.current
        let now = cal.startOfDay(for: Date())
        let endDate = cal.date(byAdding: .day, value: daysShown, to: now) ?? now
        
        return allClasses.filter { classRec in
            classRec.startDate <= endDate && classRec.endDate >= now
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if classes.isEmpty {
                    Text("No upcoming classes")
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
    @State private var daysShown = 14
    
    private var allExams: [ExamRecord] {
        (try? context.fetch(FetchDescriptor<ExamRecord>())) ?? []
    }
    
    private var dateRange: (start: Date, end: Date) {
        let cal = Calendar.current
        let now = cal.startOfDay(for: Date())
        let endDate = cal.date(byAdding: .day, value: daysShown, to: now) ?? now
        return (start: now, end: endDate)
    }
    
    var exams: [ExamRecord] {
        let range = dateRange
        var filtered: [(date: Date, exam: ExamRecord)] = []
        
        for exam in allExams {
            if exam.isRepeating {
                if let start = exam.startDate, let end = exam.endDate, start <= range.end && end >= range.start {
                    filtered.append((date: range.start, exam: exam))
                }
            } else {
                let examDate = Calendar.current.startOfDay(for: exam.date)
                if examDate >= range.start && examDate <= range.end {
                    filtered.append((date: examDate, exam: exam))
                }
            }
        }
        
        return filtered.sorted { $0.date < $1.date }.map { $0.exam }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if exams.isEmpty {
                    Text("No upcoming exams")
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
    
    var body: some View {
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
    
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

struct ClassRow: View {
    let classRec: ClassRecord
    
    var body: some View {
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
    
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

struct ExamRow: View {
    let exam: ExamRecord
    
    var body: some View {
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
    
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}