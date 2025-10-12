//
//  AddNewView.swift
//  SmartPath
//
//  Created by Assistant on 10/12/25.
//

import SwiftUI
import SwiftData

struct AddNewView: View {
    enum Tab: String, CaseIterable { case tasks = "Tasks", classes = "Classes", exams = "Exams" }
    @State private var tab: Tab = .tasks
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            VStack(spacing: 16) {
                header
                tabs
                Group {
                    switch tab {
                    case .tasks: TaskForm(context: context)
                    case .classes: ClassForm(context: context)
                    case .exams: ExamForm(context: context)
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
        .navigationTitle("Add New")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View { EmptyView() }

    private var tabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Tab.allCases, id: \.self) { t in
                    Button(action: { tab = t }) {
                        Text(t.rawValue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(t == tab ? Color.spPrimary : Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.spPrimary.opacity(0.5), lineWidth: 2)
                            )
                            .foregroundColor(t == tab ? .white : Color.spPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.4)))
            .padding(.horizontal)
        }
    }
}

// MARK: - Forms

private struct TaskForm: View {
    let context: ModelContext
    @State private var title = ""
    @State private var details = ""
    @State private var subject = ""
    @State private var repeating = false
    @State private var dueDate = Date()
    @State private var dueTime = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            field("Title") { TextField("Task Title", text: $title) }
            field("Details") { TextField("Task description", text: $details) }
            field("Subject") { TextField("Select subject", text: $subject) }
            field("Occurs") {
                HStack {
                    togglePill(label: "Once", active: !repeating) { repeating = false }
                    togglePill(label: "Repeating", active: repeating) { repeating = true }
                }
            }
            HStack {
                field("Due Date") { DatePicker("", selection: $dueDate, displayedComponents: .date).labelsHidden() }
                field("Time") { DatePicker("", selection: $dueTime, displayedComponents: .hourAndMinute).labelsHidden() }
            }
            HStack {
                Spacer()
                Button("Save Task") { save() }
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.spPrimary))
                    .foregroundColor(.white)
            }
        }
    }

    private func save() {
        let rec = TaskRecord(title: title, details: details, subject: subject, occursRepeating: repeating, dueDate: dueDate, dueTime: dueTime)
        context.insert(rec)
        try? context.save()
    }
}

private struct ExamForm: View {
    let context: ModelContext
    @State private var name = ""
    @State private var subject = ""
    @State private var type = "Exam"
    @State private var modeInPerson = true
    @State private var seat = ""
    @State private var room = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var duration = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            field("Exam") { TextField("Exam Name", text: $name) }
            field("Subject") { TextField("Select subject", text: $subject) }
            field("Type") {
                HStack { pill("Exam", sel: $type); pill("Quiz", sel: $type); pill("Test", sel: $type) }
            }
            field("Mode") {
                HStack {
                    togglePill(label: "In Person", active: modeInPerson) { modeInPerson = true }
                    togglePill(label: "Online", active: !modeInPerson) { modeInPerson = false }
                }
            }
            HStack { field("Seat") { TextField("Seat #", text: $seat) }
                    field("Room") { TextField("Room", text: $room) } }
            HStack {
                field("Date") { DatePicker("", selection: $date, displayedComponents: .date).labelsHidden() }
                field("Time") { DatePicker("", selection: $time, displayedComponents: .hourAndMinute).labelsHidden() }
            }
            field("Duration (In minutes)") { TextField("Duration (In minutes)", text: $duration).keyboardType(.numberPad) }
            HStack { Spacer(); Button("Save Exam") { save() }.padding(.horizontal,20).padding(.vertical,10).background(RoundedRectangle(cornerRadius: 14).fill(Color.spPrimary)).foregroundColor(.white) }
        }
    }

    private func save() {
        let rec = ExamRecord(name: name, subject: subject, type: type, modeInPerson: modeInPerson, seat: seat, room: room, date: date, time: time, durationMinutes: Int(duration) ?? 0)
        context.insert(rec)
        try? context.save()
    }
}

private struct ClassForm: View {
    let context: ModelContext
    @State private var modeInPerson = true
    @State private var className = ""
    @State private var room = ""
    @State private var building = ""
    @State private var teacher = ""
    @State private var subject = ""
    @State private var occursRepeating = false
    @State private var days: Set<String> = []
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            field("Mode") {
                HStack {
                    togglePill(label: "In Person", active: modeInPerson) { modeInPerson = true }
                    togglePill(label: "Online", active: !modeInPerson) { modeInPerson = false }
                }
            }
            field("Class") { TextField("Class Name", text: $className) }
            HStack { field("Room") { TextField("Room", text: $room) }
                    field("Building") { TextField("Building", text: $building) } }
            field("Teacher") { TextField("Teacher Name", text: $teacher) }
            field("Subject") { TextField("Select subject", text: $subject) }
            field("Occurs") {
                HStack { togglePill(label: "Once", active: !occursRepeating) { occursRepeating = false }
                        togglePill(label: "Repeating", active: occursRepeating) { occursRepeating = true } }
            }
            field("Days*") { dayGrid }
            HStack { field("Start Time*") { DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden() }
                    field("End Time*") { DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden() } }
            HStack { Spacer(); Button("Save Class") { save() }.padding(.horizontal,20).padding(.vertical,10).background(RoundedRectangle(cornerRadius: 14).fill(Color.spPrimary)).foregroundColor(.white) }
        }
    }

    private var dayGrid: some View {
        let all = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        return WrapHStack(spacing: 10) {
            ForEach(all, id: \.self) { d in
                let active = days.contains(d)
                Button(action: { if active { days.remove(d) } else { days.insert(d) } }) {
                    Text(d)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(active ? Color.spPrimary.opacity(0.15) : Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spPrimary.opacity(0.6), lineWidth: 2))
                        .foregroundColor(active ? Color.spPrimary : Color.spSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func save() {
        let rec = ClassRecord(
            modeInPerson: modeInPerson,
            className: className,
            room: room,
            building: building,
            teacher: teacher,
            subject: subject,
            startDate: nil,
            endDate: nil,
            occursRepeating: occursRepeating,
            daysOfWeek: Array(days),
            startTime: startTime,
            endTime: endTime
        )
        context.insert(rec)
        try? context.save()
    }
}

// MARK: - Shared UI helpers

private func field<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(label).font(.headline).foregroundColor(.black)
        ZStack {
            RoundedRectangle(cornerRadius: 14).fill(Color.white)
            RoundedRectangle(cornerRadius: 14).stroke(Color.spPrimary.opacity(0.25), lineWidth: 1)
            HStack { content() }.padding(.horizontal)
        }
        .frame(height: 48)
    }
}

private func togglePill(label: String, active: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(label)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 14).fill(active ? Color.spPrimary : Color.white))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.spPrimary.opacity(0.6), lineWidth: 2))
            .foregroundColor(active ? .white : Color.spPrimary)
    }.buttonStyle(.plain)
}

private func pill(_ title: String, sel: Binding<String>) -> some View {
    let active = sel.wrappedValue == title
    return Button(action: { sel.wrappedValue = title }) {
        Text(title)
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 14).fill(active ? Color.spPrimary : Color.white))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.spPrimary.opacity(0.6), lineWidth: 2))
            .foregroundColor(active ? .white : Color.spPrimary)
    }.buttonStyle(.plain)
}

// Simple wrapping HStack for day chips
private struct WrapHStack<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content
    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) { self.spacing = spacing; self.content = content }
    var body: some View {
        let view = HStack(spacing: spacing) { content() }
        return view
    }
}


