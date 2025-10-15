//
//  ProfileView 2.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/11/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm: ProfileViewModel
    @State private var refreshTrigger = false

    init(context: ModelContext) {
        _vm = StateObject(wrappedValue: ProfileViewModel(context: context))
      }
    
    var pendingTasksCount: Int {
        guard let tasks = try? context.fetch(FetchDescriptor<TaskRecord>()) else { return 0 }
        let cal = Calendar.current
        let now = cal.startOfDay(for: Date())
        let weekFromNow = cal.date(byAdding: .day, value: 7, to: now) ?? now
        
        var count = 0
        for task in tasks {
            if task.occurs == "Repeating" {
                if let start = task.startDate, let end = task.endDate, start <= weekFromNow && end >= now {
                    count += 1
                }
            } else {
                let taskDate = cal.startOfDay(for: task.dueDate)
                if taskDate >= now && taskDate <= weekFromNow {
                    count += 1
                }
            }
        }
        return count
    }
    
    var upcomingEventsCount: Int {
        let classCount = (try? context.fetch(FetchDescriptor<ClassRecord>()))?.count ?? 0
        let examCount = (try? context.fetch(FetchDescriptor<ExamRecord>()))?.filter { exam in
            let cal = Calendar.current
            let now = cal.startOfDay(for: Date())
            let weekFromNow = cal.date(byAdding: .day, value: 7, to: now) ?? now
            let examDate = cal.startOfDay(for: exam.date)
            return examDate >= now && examDate <= weekFromNow
        }.count ?? 0
        return classCount + examCount
    }

    var body: some View {
            NavigationStack {
                ZStack {
                    GradientBackground()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        // Photo
                        if let img = vm.student.photo {
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 60))
                                .foregroundColor(Color.spSecondary)
                                )
                        }

                        // Info rows
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(label: "First Name", value: vm.student.firstName)
                            InfoRow(label: "Last Name",  value: vm.student.lastName)
                            InfoRow(label: "Email",      value: vm.student.email)
                        }
                        .padding(.horizontal)


                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { vm.startEditing() } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.black)
                        }
                    }
                }
                .sheet(isPresented: $vm.isEditing) {
                    EditProfileView(viewModel: vm)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80)
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshCalendar"))) { _ in
                    refreshTrigger.toggle()
                }
            }
        }
    }

    private struct InfoRow: View {
        let label: String, value: String
        var body: some View {
            HStack {
                Text(label)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
                Text(value)
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding(.vertical, 4)
        }
    }


// MARK: - Real Task List View (from Database)
struct RealTaskListView: View {
    let context: ModelContext
    
    private var grouped: [(date: Date, items: [TaskRecord])] {
        guard let tasks = try? context.fetch(FetchDescriptor<TaskRecord>()) else { return [] }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 7, to: start)!
        
        var dateMap: [Date: [TaskRecord]] = [:]
        
        for task in tasks {
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
                        Text("No tasks in the next 7 days")
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


// MARK: - Real Event List View (from Database)
struct RealEventListView: View {
    let context: ModelContext
    
    private var grouped: [(date: Date, items: [(type: String, record: Any)])] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 7, to: start)!
        
        var dateMap: [Date: [(type: String, record: Any)]] = [:]
        
        // Get classes
        if let classes = try? context.fetch(FetchDescriptor<ClassRecord>()) {
            for classRec in classes {
                var current = max(start, cal.startOfDay(for: classRec.startDate))
                let rangeEnd = min(end, cal.startOfDay(for: classRec.endDate))
                
                while current < rangeEnd {
                    let weekdayFormatter = DateFormatter()
                    weekdayFormatter.dateFormat = "EEE"
                    let dayAbbr = weekdayFormatter.string(from: current).prefix(3)
                    
                    if classRec.days.contains(where: { $0.prefix(3) == dayAbbr }) {
                        if dateMap[current] == nil { dateMap[current] = [] }
                        dateMap[current]?.append((type: "class", record: classRec))
                    }
                    current = cal.date(byAdding: .day, value: 1, to: current) ?? current
                }
            }
        }
        
        // Get exams
        if let exams = try? context.fetch(FetchDescriptor<ExamRecord>()) {
            for exam in exams {
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
                                dateMap[current]?.append((type: "exam", record: exam))
                            }
                            current = cal.date(byAdding: .day, value: 1, to: current) ?? current
                        }
                    }
                } else {
                    let examDate = cal.startOfDay(for: exam.date)
                    if examDate >= start && examDate < end {
                        if dateMap[examDate] == nil { dateMap[examDate] = [] }
                        dateMap[examDate]?.append((type: "exam", record: exam))
                    }
                }
            }
        }
        
        return dateMap.map { (date: $0.key, items: $0.value) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                    if grouped.isEmpty {
                        Text("No events in the next 7 days")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                            .padding()
                    } else {
                        ForEach(grouped, id: \.date) { bucket in
                            Section(header: header(bucket.date, count: bucket.items.count)) {
                                ForEach(bucket.items.indices, id: \.self) { index in
                                    let item = bucket.items[index]
                                    if item.type == "class", let classRec = item.record as? ClassRecord {
                                        ClassRow(classRec: classRec)
                                            .padding(.horizontal)
                                    } else if item.type == "exam", let exam = item.record as? ExamRecord {
                                        ExamRow(exam: exam)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Upcoming Events")
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

