//
//  TimerViews.swift
//  SmartPath
//
//  Created by Assistant on 10/14/25.
//

import SwiftUI
import SwiftData

struct TimerView: View {
    @StateObject private var vm = TimerViewModel()
    @Environment(\.modelContext) private var context
    @State private var showSettings = false
    @State private var showChecklist = true

    private var progress: Double {
        guard vm.totalSecondsForPhase > 0 else { return 0 }
        let elapsed = Double(vm.totalSecondsForPhase - vm.secondsRemaining)
        return max(0, min(1, elapsed / Double(vm.totalSecondsForPhase)))
    }

    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Timer")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.black)
                        Text(titleText())
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }

                    ZStack {
                        Circle()
                            .stroke(Color.black.opacity(0.06), lineWidth: 18)
                            .frame(width: 260, height: 260)

                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(AngularGradient(colors: [Color.spPrimary.opacity(0.3), Color.spPrimary], center: .center), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .frame(width: 260, height: 260)

                        VStack(spacing: 6) {
                            Text(vm.phase == .focus ? "Focus" : (vm.phase == .shortBreak ? "Short Break" : "Long Break"))
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.7))
                            Text(vm.formattedTime())
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(Color.spPrimary)
                        }
                    }

                    HStack(spacing: 24) {
                        Button { vm.reset() } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 56, height: 56)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }

                        Button { vm.toggle() } label: {
                            Image(systemName: vm.isRunning ? "pause" : "play")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color.spPrimary)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 6)
                        }

                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20, weight: .semibold))
                                .frame(width: 56, height: 56)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }
                    }

                    // Checklist
                    DisclosureGroup(isExpanded: $showChecklist) {
                        TaskChecklist(selectedTaskIds: $vm.selectedTaskIds)
                            .environment(\.modelContext, context)
                            .padding(.top, 8)
                    } label: {
                        Text("Checklist")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showSettings, onDismiss: { vm.openSettingsApplied() }) {
            TimerSettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PomodoroCompleted"))) { _ in
            addPomodoroToStreak()
        }
    }

    private func titleText() -> String {
        return "Find your focus\nShort sessions add up to big progress."
    }
    
    private func addPomodoroToStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let streakRecord = StreakRecord(
            date: today,
            activityType: "pomodoro",
            activityTitle: "Pomodoro Session",
            activityDetails: "\(vm.focusMinutes) minute focus session"
        )
        context.insert(streakRecord)
        try? context.save()
        
        // Notify streak view to refresh
        NotificationCenter.default.post(name: NSNotification.Name("RefreshStreak"), object: nil)
    }
}

struct TimerSettingsView: View {
    @AppStorage("timer.focusMinutes") private var focusMinutes: Int = 25
    @AppStorage("timer.shortBreakMinutes") private var shortBreakMinutes: Int = 5
    @AppStorage("timer.longBreakMinutes") private var longBreakMinutes: Int = 15
    @AppStorage("timer.longBreakInterval") private var longBreakInterval: Int = 4
    @AppStorage("timer.alertSoundEnabled") private var alertSoundEnabled: Bool = true

    private let focusOptions = [10, 15, 20, 25, 30, 45, 50, 60]
    private let breakOptions = [3, 5, 10, 15, 20, 25]
    private let longBreakOptions = [15, 20, 25, 30, 35]
    private let intervalOptions = [2, 3, 4, 5]

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground().ignoresSafeArea()
                Form {
                    Section("Focus Time") {
                        Picker("Focus Time", selection: $focusMinutes) {
                            ForEach(focusOptions, id: \.self) { m in
                                Text("\(m) Minutes").tag(m)
                            }
                        }.pickerStyle(.menu)
                    }
                    Section("Short Break") {
                        Picker("Short Break", selection: $shortBreakMinutes) {
                            ForEach(breakOptions, id: \.self) { m in
                                Text("\(m) Minutes").tag(m)
                            }
                        }.pickerStyle(.menu)
                    }
                    Section("Long Break") {
                        Picker("Long Break", selection: $longBreakMinutes) {
                            ForEach(longBreakOptions, id: \.self) { m in
                                Text("\(m) Minutes").tag(m)
                            }
                        }.pickerStyle(.menu)
                    }
                    Section("Long Break Interval") {
                        Picker("Long Break Interval", selection: $longBreakInterval) {
                            ForEach(intervalOptions, id: \.self) { i in
                                Text("\(i) intervals").tag(i)
                            }
                        }.pickerStyle(.menu)
                    }
                    Section {
                        Toggle("Alert Sound", isOn: $alertSoundEnabled)
                    }
                }
            }
            .navigationTitle("Pomodoro Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TaskChecklist: View {
    @Environment(\.modelContext) private var context
    @Binding var selectedTaskIds: Set<String>

    private var upcomingTasks: [TaskRecord] {
        let all: [TaskRecord] = (try? context.fetch(FetchDescriptor<TaskRecord>())) ?? []
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 14, to: start) ?? start

        var result: [(key: Date, task: TaskRecord)] = []
        for t in all {
            // Skip completed tasks - they shouldn't appear in the checklist
            if t.isCompleted {
                continue
            }
            
            if t.occurs == "Repeating" {
                if let s = t.startDate, let e = t.endDate, s <= end && e >= start {
                    result.append((key: start, task: t))
                }
            } else {
                let d = cal.startOfDay(for: t.dueDate)
                if d >= start && d <= end { result.append((key: d, task: t)) }
            }
        }

        return result.sorted { $0.key < $1.key }.map { $0.task }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if upcomingTasks.isEmpty {
                Text("No tasks due in next 14 days")
                    .font(.footnote)
                    .foregroundColor(.black.opacity(0.6))
            } else {
                ForEach(upcomingTasks, id: \.self) { task in
                    ChecklistRow(task: task, isSelected: selectedTaskIds.contains(key(for: task))) {
                        toggle(task)
                    }
                }
            }
        }
    }

    private func toggle(_ task: TaskRecord) {
        let k = key(for: task)
        if selectedTaskIds.contains(k) { selectedTaskIds.remove(k) }
        else { selectedTaskIds.insert(k) }
    }

    private func key(for task: TaskRecord) -> String {
        let dateKey = task.dueDate.timeIntervalSince1970
        let timeKey = task.dueTime.timeIntervalSince1970
        return "\(task.title)|\(dateKey)|\(timeKey)"
    }
}

private struct ChecklistRow: View {
    let task: TaskRecord
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: action) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color.spPrimary : .black.opacity(0.3))
                    .font(.system(size: 20, weight: .semibold))
            }
            .buttonStyle(.plain)

            NavigationLink(destination: TaskDetailView(task: task)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                    Text("\(dateString(task.dueDate))  •  \(timeString(task.dueTime))")
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.6))
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func dateString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: d)
    }

    private func timeString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: d)
    }
}


