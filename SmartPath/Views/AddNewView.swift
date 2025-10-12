//
//  AddNewView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 10/12/25.
//

import SwiftUI
import SwiftData

private enum AddTab: String, CaseIterable, Identifiable { case task = "Tasks", classes = "Classes", exam = "Exams"; var id: String { rawValue } }

struct AddNewView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @State private var selected: AddTab = .task

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Add New").font(.title2).padding(.top, 8)
        tabBar
        Group {
          switch selected {
          case .task: TaskForm(context: context)
          case .classes: ClassForm(context: context)
          case .exam: ExamForm(context: context)
          }
        }
      }
      .padding()
    }
    .background(GradientBackground())
    .navigationBarTitleDisplayMode(.inline)
  }

  private var tabBar: some View {
    HStack(spacing: 12) {
      ForEach(AddTab.allCases) { tab in
        Button(action: { selected = tab }) {
          Text(tab.rawValue)
            .font(.headline)
            .foregroundColor(selected == tab ? .white : Color.spPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
              RoundedRectangle(cornerRadius: 14)
                .fill(selected == tab ? Color.spPrimary : Color.white.opacity(0.8))
            )
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .stroke(Color.spPrimary.opacity(0.6), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
      }
      Spacer()
    }
    .padding(8)
    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.4)))
  }
}

// MARK: - Task Form

private struct TaskForm: View {
  let context: ModelContext
  @State private var title = ""
  @State private var details = ""
  @State private var subject = ""
  @State private var occurs = "Once"
  @State private var dueDate = Date()
  @State private var dueTime = Date()

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Title").bold()
      TextField("Task Title", text: $title).textFieldStyle(.roundedBorder)

      Text("Details").bold()
      TextField("Task description", text: $details).textFieldStyle(.roundedBorder)

      Text("Subject").bold()
      TextField("Select subject", text: $subject).textFieldStyle(.roundedBorder)

      Text("Occurs").bold()
      HStack {
        choicePill("Once", selection: $occurs)
        choicePill("Repeating", selection: $occurs)
      }

      HStack {
        VStack(alignment: .leading) {
          Text("Due Date").bold()
          DatePicker("", selection: $dueDate, displayedComponents: .date).labelsHidden()
        }
        VStack(alignment: .leading) {
          Text("Time").bold()
          DatePicker("", selection: $dueTime, displayedComponents: .hourAndMinute).labelsHidden()
        }
      }

      HStack {
        Button("Cancel") { reset() }
          .buttonStyle(.bordered)
          .tint(Color.spPrimary.opacity(0.3))
        Spacer()
        Button("Save Task") { save() }
          .buttonStyle(.borderedProminent)
          .tint(Color.spPrimary)
      }
      .padding(.top, 8)
    }
  }

  // uses shared choicePill defined at file scope

  private func save() {
    let item = TaskRecord(title: title, details: details, subject: subject, occurs: occurs, dueDate: dueDate, dueTime: dueTime)
    context.insert(item)
    try? context.save()
    reset()
  }

  private func reset() { title = ""; details = ""; subject = ""; occurs = "Once"; dueDate = Date(); dueTime = Date() }
}

// MARK: - Exam Form

private struct ExamForm: View {
  let context: ModelContext
  @State private var name = ""
  @State private var subject = ""
  @State private var examType = "Exam"
  @State private var mode = "In Person"
  @State private var seat = ""
  @State private var room = ""
  @State private var date = Date()
  @State private var time = Date()
  @State private var duration = 60

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Exam").bold()
      TextField("Exam Name", text: $name).textFieldStyle(.roundedBorder)

      Text("Subject").bold()
      TextField("Select subject", text: $subject).textFieldStyle(.roundedBorder)

      Text("Type").bold()
      HStack { choicePill("Exam", selection: $examType); choicePill("Quiz", selection: $examType); choicePill("Test", selection: $examType) }

      Text("Mode").bold()
      HStack { choicePill("In Person", selection: $mode); choicePill("Online", selection: $mode) }

      HStack {
        VStack(alignment: .leading) { Text("Seat").bold(); TextField("Seat #", text: $seat).textFieldStyle(.roundedBorder) }
        VStack(alignment: .leading) { Text("Room").bold(); TextField("Room", text: $room).textFieldStyle(.roundedBorder) }
      }

      HStack {
        VStack(alignment: .leading) { Text("Date").bold(); DatePicker("", selection: $date, displayedComponents: .date).labelsHidden() }
        VStack(alignment: .leading) { Text("Time").bold(); DatePicker("", selection: $time, displayedComponents: .hourAndMinute).labelsHidden() }
      }

      VStack(alignment: .leading) { Text("Duration (In minutes)").bold(); TextField("Duration (In minutes)", value: $duration, formatter: NumberFormatter()).textFieldStyle(.roundedBorder) }

      HStack { Button("Cancel") { reset() }.buttonStyle(.bordered).tint(Color.spPrimary.opacity(0.3)); Spacer(); Button("Save Exam") { save() }.buttonStyle(.borderedProminent).tint(Color.spPrimary) }.padding(.top, 8)
    }
  }

  // uses shared choicePill defined at file scope

  private func save() {
    let record = ExamRecord(name: name, subject: subject, examType: examType, mode: mode, seat: seat, room: room, date: date, time: time, durationMinutes: duration)
    context.insert(record)
    try? context.save()
    reset()
  }

  private func reset() { name = ""; subject = ""; examType = "Exam"; mode = "In Person"; seat = ""; room = ""; date = Date(); time = Date(); duration = 60 }
}

// MARK: - Class Form

private struct ClassForm: View {
  let context: ModelContext
  @State private var mode = "In Person"
  @State private var className = ""
  @State private var room = ""
  @State private var building = ""
  @State private var teacher = ""
  @State private var subject = ""
  @State private var occurs = "Once"
  @State private var days: Set<String> = []
  @State private var startTime = Date()
  @State private var endTime = Date()

  private let weekdayLabels = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Mode").bold()
      HStack { choicePill("In Person", selection: $mode); choicePill("Online", selection: $mode) }

      Text("Class").bold()
      TextField("Class Name", text: $className).textFieldStyle(.roundedBorder)

      HStack { VStack(alignment: .leading) { Text("Room").bold(); TextField("Room", text: $room).textFieldStyle(.roundedBorder) }; VStack(alignment: .leading) { Text("Building").bold(); TextField("Building", text: $building).textFieldStyle(.roundedBorder) } }

      Text("Teacher").bold(); TextField("Teacher Name", text: $teacher).textFieldStyle(.roundedBorder)

      Text("Subject").bold(); TextField("Select subject", text: $subject).textFieldStyle(.roundedBorder)

      Text("Occurs").bold(); HStack { choicePill("Once", selection: $occurs); choicePill("Repeating", selection: $occurs) }

      Text("Days*").bold()
      FlowLayout(alignment: .leading, spacing: 10) {
        ForEach(weekdayLabels, id: \.self) { d in
          Button(action: { toggleDay(d) }) {
            Text(d)
              .padding(.horizontal, 14)
              .padding(.vertical, 8)
              .background(RoundedRectangle(cornerRadius: 12).fill(days.contains(d) ? Color.spPrimary : Color.clear))
              .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spPrimary.opacity(0.6), lineWidth: 2))
              .foregroundColor(days.contains(d) ? .white : Color.spPrimary)
          }.buttonStyle(.plain)
        }
      }

      HStack { VStack(alignment: .leading) { Text("Start Time*").bold(); DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden() }; VStack(alignment: .leading) { Text("End Time*").bold(); DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden() } }

      HStack { Button("Cancel") { reset() }.buttonStyle(.bordered).tint(Color.spPrimary.opacity(0.3)); Spacer(); Button("Save Class") { save() }.buttonStyle(.borderedProminent).tint(Color.spPrimary) }.padding(.top, 8)
    }
  }

  // uses shared choicePill defined at file scope

  private func toggleDay(_ d: String) { if days.contains(d) { days.remove(d) } else { days.insert(d) } }

  private func save() { let rec = ClassRecord(mode: mode, className: className, room: room, building: building, teacher: teacher, subject: subject, occurs: occurs, days: Array(days).sorted(), startTime: startTime, endTime: endTime); context.insert(rec); try? context.save(); reset() }

  private func reset() { mode = "In Person"; className = ""; room = ""; building = ""; teacher = ""; subject = ""; occurs = "Once"; days = []; startTime = Date(); endTime = Date() }
}

// Simple flow layout for days chips
private struct FlowLayout<Content: View>: View {
  let alignment: HorizontalAlignment
  let spacing: CGFloat
  @ViewBuilder let content: Content
  init(alignment: HorizontalAlignment, spacing: CGFloat, @ViewBuilder content: () -> Content) { self.alignment = alignment; self.spacing = spacing; self.content = content() }
  var body: some View { VStack(alignment: alignment, spacing: spacing) { content } }
}

// Shared pill selector used by forms
private func choicePill(_ value: String, selection: Binding<String>) -> some View {
  Button(action: { selection.wrappedValue = value }) {
    Text(value)
      .padding(.horizontal, 14)
      .padding(.vertical, 8)
      .background(
        RoundedRectangle(cornerRadius: 12).fill(selection.wrappedValue == value ? Color.spPrimary : Color.clear)
      )
      .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spPrimary.opacity(0.6), lineWidth: 2))
      .foregroundColor(selection.wrappedValue == value ? .white : Color.spPrimary)
  }
  .buttonStyle(.plain)
}

