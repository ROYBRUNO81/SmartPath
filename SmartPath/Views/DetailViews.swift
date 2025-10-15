//
//  DetailViews.swift
//  SmartPath
//
//  Created by Assistant on 10/14/25.
//

import SwiftUI
import SwiftData

// MARK: - Task Detail View
struct TaskDetailView: View {
    let task: TaskRecord
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    @State private var deleteAllRepeating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card
                        VStack(spacing: 16) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: task.colorHex))
                                    .frame(width: 12, height: 12)
                                
                                Text(task.title)
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            if !task.details.isEmpty {
                                HStack {
                                    Text(task.details)
                                        .font(.body)
                                        .foregroundColor(.black.opacity(0.7))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Details Card
                        VStack(spacing: 16) {
                            DetailRow(title: "Type", value: task.occurs)
                            DetailRow(title: "Due Date", value: dateString(task.dueDate))
                            DetailRow(title: "Due Time", value: timeString(task.dueTime))
                            
                            if task.occurs == "Repeating" {
                                if let startDate = task.startDate {
                                    DetailRow(title: "Start Date", value: dateString(startDate))
                                }
                                if let endDate = task.endDate {
                                    DetailRow(title: "End Date", value: dateString(endDate))
                                }
                                if !task.days.isEmpty {
                                    DetailRow(title: "Days", value: task.days.joined(separator: ", "))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Completion Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Completion")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            
                            if task.isCompleted {
                                // Completed State - Show completion status
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    Text("Task Completed")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.green, lineWidth: 2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Text("This task has been completed and moved to past tasks.")
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.6))
                                    .multilineTextAlignment(.center)
                            } else {
                                // Not Completed - Show completion controls
                                // Completion Toggle
                                HStack {
                                    Button(action: { toggleCompletion() }) {
                                        HStack {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                            Text("Mark Complete")
                                                .foregroundColor(.black)
                                        }
                                        .font(.headline)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray, lineWidth: 2))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                // Progress Slider
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Progress")
                                            .font(.subheadline)
                                            .foregroundColor(.black.opacity(0.7))
                                        Spacer()
                                        Text("\(task.completionPercentage)%")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.black)
                                    }
                                    
                                    Slider(value: Binding(
                                        get: { Double(task.completionPercentage) },
                                        set: { newValue in
                                            task.completionPercentage = Int(newValue)
                                            if task.completionPercentage == 100 {
                                                task.isCompleted = true
                                                // Add to streak when completed
                                                addToStreak(activityType: "task", title: task.title, details: task.details)
                                                try? context.save()
                                                // Notify menu to refresh counts and streak
                                                NotificationCenter.default.post(name: NSNotification.Name("RefreshMenuCounts"), object: nil)
                                                NotificationCenter.default.post(name: NSNotification.Name("RefreshStreak"), object: nil)
                                                // Dismiss the view after completion
                                                dismiss()
                                            } else if task.completionPercentage < 100 {
                                                task.isCompleted = false
                                                try? context.save()
                                            }
                                        }
                                    ), in: 0...100, step: 5)
                                    .accentColor(Color.spPrimary)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Delete Button
                        Button(action: { showDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Task")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            if task.occurs == "Repeating" {
                Button("Delete This Instance", role: .destructive) {
                    deleteTask(deleteAll: false)
                }
                Button("Delete All Repeating", role: .destructive) {
                    deleteTask(deleteAll: true)
                }
                Button("Cancel", role: .cancel) { }
            } else {
                Button("Delete", role: .destructive) {
                    deleteTask(deleteAll: false)
                }
                Button("Cancel", role: .cancel) { }
            }
        } message: {
            if task.occurs == "Repeating" {
                Text("This is a repeating task. Do you want to delete just this instance or all future occurrences?")
            } else {
                Text("Are you sure you want to delete this task? This action cannot be undone.")
            }
        }
    }
    
    private func toggleCompletion() {
        if !task.isCompleted {
            task.isCompleted = true
            task.completionPercentage = 100
            // Add to streak immediately when completed
            addToStreak(activityType: "task", title: task.title, details: task.details)
            try? context.save()
            // Notify menu to refresh counts and streak
            NotificationCenter.default.post(name: NSNotification.Name("RefreshMenuCounts"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("RefreshStreak"), object: nil)
            // Dismiss the view after completion
            dismiss()
        }
    }
    
    private func addToStreak(activityType: String, title: String, details: String) {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if streak record already exists for this task today
        let descriptor = FetchDescriptor<StreakRecord>()
        if let existingStreaks = try? context.fetch(descriptor) {
            let alreadyExists = existingStreaks.contains { streak in
                Calendar.current.isDate(streak.date, inSameDayAs: today) &&
                streak.activityType == activityType &&
                streak.activityTitle == title
            }
            
            if !alreadyExists {
                let streakRecord = StreakRecord(
                    date: today,
                    activityType: activityType,
                    activityTitle: title,
                    activityDetails: details
                )
                context.insert(streakRecord)
                try? context.save()
            }
        }
    }
    
    private func deleteTask(deleteAll: Bool) {
        if deleteAll && task.occurs == "Repeating" {
            // Delete all repeating tasks with same title and details
            let descriptor = FetchDescriptor<TaskRecord>()
            if let allTasks = try? context.fetch(descriptor) {
                let matchingTasks = allTasks.filter { t in
                    t.title == task.title && t.details == task.details && t.occurs == "Repeating"
                }
                for t in matchingTasks {
                    context.delete(t)
                }
            }
        } else {
            context.delete(task)
        }
        
        try? context.save()
        dismiss()
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Class Detail View
struct ClassDetailView: View {
    let classRecord: ClassRecord
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card
                        VStack(spacing: 16) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: classRecord.colorHex))
                                    .frame(width: 12, height: 12)
                                
                                Text(classRecord.className)
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text("Taught by \(classRecord.teacher)")
                                    .font(.body)
                                    .foregroundColor(.black.opacity(0.7))
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Details Card
                        VStack(spacing: 16) {
                            DetailRow(title: "Mode", value: classRecord.mode)
                            DetailRow(title: "Days", value: classRecord.days.joined(separator: ", "))
                            DetailRow(title: "Time", value: "\(timeString(classRecord.startTime)) - \(timeString(classRecord.endTime))")
                            DetailRow(title: "Location", value: classRecord.mode == "Online" ? "Online" : "\(classRecord.building) \(classRecord.room)")
                            DetailRow(title: "Start Date", value: dateString(classRecord.startDate))
                            DetailRow(title: "End Date", value: dateString(classRecord.endDate))
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Delete Button
                        Button(action: { showDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Class")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Class Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("Delete Class", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                context.delete(classRecord)
                try? context.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this class? This action cannot be undone.")
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Exam Detail View
struct ExamDetailView: View {
    let exam: ExamRecord
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card
                        VStack(spacing: 16) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: exam.colorHex))
                                    .frame(width: 12, height: 12)
                                
                                Text(exam.name)
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text(exam.examType == "Other" ? exam.customType : exam.examType)
                                    .font(.body)
                                    .foregroundColor(.black.opacity(0.7))
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Details Card
                        VStack(spacing: 16) {
                            DetailRow(title: "Type", value: exam.examType == "Other" ? exam.customType : exam.examType)
                            DetailRow(title: "Mode", value: exam.mode)
                            DetailRow(title: "Date", value: dateString(exam.date))
                            DetailRow(title: "Time", value: timeString(exam.time))
                            DetailRow(title: "Duration", value: "\(exam.durationMinutes) minutes")
                            
                            if exam.mode == "Online" && !exam.link.isEmpty {
                                DetailRow(title: "Link", value: exam.link)
                            } else if exam.mode == "In Person" {
                                DetailRow(title: "Location", value: "\(exam.building) \(exam.room)")
                            }
                            
                            if exam.isRepeating {
                                if let startDate = exam.startDate {
                                    DetailRow(title: "Start Date", value: dateString(startDate))
                                }
                                if let endDate = exam.endDate {
                                    DetailRow(title: "End Date", value: dateString(endDate))
                                }
                                if !exam.days.isEmpty {
                                    DetailRow(title: "Days", value: exam.days.joined(separator: ", "))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        
                        // Delete Button
                        Button(action: { showDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Exam")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Exam Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("Delete Exam", isPresented: $showDeleteAlert) {
            if exam.isRepeating {
                Button("Delete This Instance", role: .destructive) {
                    deleteExam(deleteAll: false)
                }
                Button("Delete All Repeating", role: .destructive) {
                    deleteExam(deleteAll: true)
                }
                Button("Cancel", role: .cancel) { }
            } else {
                Button("Delete", role: .destructive) {
                    deleteExam(deleteAll: false)
                }
                Button("Cancel", role: .cancel) { }
            }
        } message: {
            if exam.isRepeating {
                Text("This is a repeating exam. Do you want to delete just this instance or all future occurrences?")
            } else {
                Text("Are you sure you want to delete this exam? This action cannot be undone.")
            }
        }
    }
    
    
    private func deleteExam(deleteAll: Bool) {
        if deleteAll && exam.isRepeating {
            // Delete all repeating exams with same name and type
            let descriptor = FetchDescriptor<ExamRecord>()
            if let allExams = try? context.fetch(descriptor) {
                let matchingExams = allExams.filter { e in
                    e.name == exam.name && e.examType == exam.examType && e.isRepeating
                }
                for e in matchingExams {
                    context.delete(e)
                }
            }
        } else {
            context.delete(exam)
        }
        
        try? context.save()
        dismiss()
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Event Detail View
struct EventDetailView: View {
    let event: EventItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Card
                        VStack(spacing: 16) {
                            HStack {
                                Circle()
                                    .fill(color(for: event.type).opacity(0.2))
                                    .frame(width: 12, height: 12)
                                
                                Text(event.title)
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text(event.type.rawValue)
                                    .font(.body)
                                    .foregroundColor(.black.opacity(0.7))
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Details Card
                        VStack(spacing: 16) {
                            DetailRow(title: "Type", value: event.type.rawValue)
                            DetailRow(title: "Date", value: dateString(event.date))
                            DetailRow(title: "Start Time", value: timeString(event.startTime))
                            DetailRow(title: "End Time", value: timeString(event.endTime))
                            DetailRow(title: "Repeating", value: event.repeating.rawValue)
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding()
                }
            }
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func color(for type: EventType) -> Color {
        switch type {
        case .classSession: return .blue
        case .interview: return .green
        case .coffeeChat: return .orange
        case .campusEvent: return .purple
        case .exam: return .red
        case .holiday: return .yellow
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.black.opacity(0.6))
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.black)
                .multilineTextAlignment(.trailing)
            
            Spacer()
        }
    }
}
