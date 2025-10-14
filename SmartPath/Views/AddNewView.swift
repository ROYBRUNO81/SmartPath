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
          case .task: TaskForm(context: context, dismiss: dismiss)
          case .classes: ClassForm(context: context, dismiss: dismiss)
          case .exam: ExamForm(context: context, dismiss: dismiss)
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
  let dismiss: DismissAction
  @State private var title = ""
  @State private var details = ""
  @State private var occurs = "Once"
  @State private var dueDate = Date()
  @State private var dueTime = Date()
  @State private var days: Set<String> = []
  @State private var startDate = Date()
  @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()

  private let weekdayLabels = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Title*").bold()
      TextField("Task Title", text: $title).textFieldStyle(.roundedBorder)

      Text("Details").bold()
      TextEditor(text: $details)
        .frame(height: 100)
        .padding(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )

      Text("Occurs").bold()
      HStack {
        choicePill("Once", selection: $occurs)
        choicePill("Repeating", selection: $occurs)
      }

      if occurs == "Repeating" {
        Text("Repeat Days*").bold()
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

        HStack {
          VStack(alignment: .leading) {
            Text("Start Date*").bold()
            DatePicker("", selection: $startDate, displayedComponents: .date).labelsHidden()
          }
          VStack(alignment: .leading) {
            Text("End Date*").bold()
            DatePicker("", selection: $endDate, displayedComponents: .date).labelsHidden()
          }
        }
      } else {
        VStack(alignment: .leading) {
          Text("Due Date*").bold()
          DatePicker("", selection: $dueDate, displayedComponents: .date).labelsHidden()
        }
      }

      VStack(alignment: .leading) {
        Text("Time*").bold()
        DatePicker("", selection: $dueTime, displayedComponents: .hourAndMinute).labelsHidden()
      }

      HStack {
        Button("Cancel") { dismiss() }
          .buttonStyle(.bordered)
          .tint(Color.spPrimary.opacity(0.3))
        Spacer()
        Button("Save Task") { save() }
          .buttonStyle(.borderedProminent)
          .tint(Color.spPrimary)
          .disabled(title.isEmpty || (occurs == "Repeating" && days.isEmpty))
      }
      .padding(.top, 8)
    }
  }

  private func toggleDay(_ d: String) { if days.contains(d) { days.remove(d) } else { days.insert(d) } }

  private func save() {
    let item = TaskRecord(
      title: title,
      details: details,
      occurs: occurs,
      dueDate: dueDate,
      dueTime: dueTime,
      days: occurs == "Repeating" ? Array(days).sorted() : [],
      startDate: occurs == "Repeating" ? startDate : nil,
      endDate: occurs == "Repeating" ? endDate : nil
    )
    context.insert(item)
    try? context.save()
    dismiss()
  }
}

// MARK: - Exam Form

private struct ExamForm: View {
  let context: ModelContext
  let dismiss: DismissAction
  @State private var name = ""
  @State private var examType = "Midterm 1"
  @State private var customType = ""
  @State private var mode = "In Person"
  @State private var room = ""
  @State private var building = ""
  @State private var link = ""
  @State private var date = Date()
  @State private var time = Date()
  @State private var duration = 60
  @State private var days: Set<String> = []
  @State private var startDate = Date()
  @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()

  private let examTypes = ["Midterm 1", "Midterm 2", "Final", "Quiz", "Other"]
  private let weekdayLabels = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Name*").bold()
      TextField("Exam Name", text: $name).textFieldStyle(.roundedBorder)

      Text("Type*").bold()
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(examTypes, id: \.self) { type in
            choicePill(type, selection: $examType)
          }
        }
      }

      if examType == "Other" {
        Text("Custom Type").bold()
        TextField("Enter exam type", text: $customType).textFieldStyle(.roundedBorder)
      }

      Text("Mode").bold()
      HStack { choicePill("In Person", selection: $mode); choicePill("Online", selection: $mode) }

      if mode == "Online" {
        Text("Link").bold()
        TextField("Meeting link", text: $link).textFieldStyle(.roundedBorder)
      } else {
        HStack {
          VStack(alignment: .leading) { 
            Text("Room").bold()
            TextField("Room", text: $room).textFieldStyle(.roundedBorder)
          }
          VStack(alignment: .leading) { 
            Text("Building").bold()
            TextField("Building", text: $building).textFieldStyle(.roundedBorder)
          }
        }
      }

      if examType == "Quiz" {
        Text("Quiz Repeat Days (optional)").bold()
        Text("Leave empty for one-time quiz")
          .font(.caption)
          .foregroundColor(.gray)
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

        if !days.isEmpty {
          HStack {
            VStack(alignment: .leading) {
              Text("Start Date*").bold()
              DatePicker("", selection: $startDate, displayedComponents: .date).labelsHidden()
            }
            VStack(alignment: .leading) {
              Text("End Date*").bold()
              DatePicker("", selection: $endDate, displayedComponents: .date).labelsHidden()
            }
          }
        } else {
          VStack(alignment: .leading) {
            Text("Date*").bold()
            DatePicker("", selection: $date, displayedComponents: .date).labelsHidden()
          }
        }
      } else {
        VStack(alignment: .leading) {
          Text("Date*").bold()
          DatePicker("", selection: $date, displayedComponents: .date).labelsHidden()
        }
      }

      HStack {
        VStack(alignment: .leading) {
          Text("Time*").bold()
          DatePicker("", selection: $time, displayedComponents: .hourAndMinute).labelsHidden()
        }
        VStack(alignment: .leading) {
          Text("Duration (min)*").bold()
          TextField("Duration", value: $duration, formatter: NumberFormatter()).textFieldStyle(.roundedBorder)
        }
      }

      HStack {
        Button("Cancel") { dismiss() }
          .buttonStyle(.bordered)
          .tint(Color.spPrimary.opacity(0.3))
        Spacer()
        Button("Save Exam") { save() }
          .buttonStyle(.borderedProminent)
          .tint(Color.spPrimary)
          .disabled(name.isEmpty || (examType == "Other" && customType.isEmpty))
      }
      .padding(.top, 8)
    }
  }

  private func toggleDay(_ d: String) { if days.contains(d) { days.remove(d) } else { days.insert(d) } }

  private func save() {
    let isRepeating = examType == "Quiz" && !days.isEmpty
    let record = ExamRecord(
      name: name,
      examType: examType,
      customType: customType,
      mode: mode,
      room: room,
      building: building,
      link: link,
      date: date,
      time: time,
      durationMinutes: duration,
      isRepeating: isRepeating,
      days: isRepeating ? Array(days).sorted() : [],
      startDate: isRepeating ? startDate : nil,
      endDate: isRepeating ? endDate : nil
    )
    context.insert(record)
    try? context.save()
    dismiss()
  }
}

// MARK: - Class Form

private struct ClassForm: View {
  let context: ModelContext
  let dismiss: DismissAction
  @State private var mode = "In Person"
  @State private var className = ""
  @State private var room = ""
  @State private var building = ""
  @State private var teacher = ""
  @State private var days: Set<String> = []
  @State private var startTime = Date()
  @State private var endTime = Date()
  @State private var startDate = Date()
  @State private var endDateValue = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()

  private let weekdayLabels = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Mode").bold()
      HStack { choicePill("In Person", selection: $mode); choicePill("Online", selection: $mode) }

      Text("Class Name*").bold()
      TextField("Class Name", text: $className).textFieldStyle(.roundedBorder)

      HStack { 
        VStack(alignment: .leading) { 
          Text("Room").bold()
          TextField("Room", text: $room).textFieldStyle(.roundedBorder)
        }
        VStack(alignment: .leading) { 
          Text("Building").bold()
          TextField("Building", text: $building).textFieldStyle(.roundedBorder)
        }
      }

      Text("Teacher").bold()
      TextField("Teacher Name", text: $teacher).textFieldStyle(.roundedBorder)

      Text("Repeat Days*").bold()
      Text("Select which days of the week this class occurs")
        .font(.caption)
        .foregroundColor(.gray)
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

      HStack { 
        VStack(alignment: .leading) { 
          Text("Start Time*").bold()
          DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute).labelsHidden()
        }
        VStack(alignment: .leading) { 
          Text("End Time*").bold()
          DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute).labelsHidden()
        }
      }

      HStack { 
        VStack(alignment: .leading) { 
          Text("Start Date*").bold()
          DatePicker("", selection: $startDate, displayedComponents: .date).labelsHidden()
        }
        VStack(alignment: .leading) { 
          Text("End Date*").bold()
          DatePicker("", selection: $endDateValue, displayedComponents: .date).labelsHidden()
        }
      }

      HStack { 
        Button("Cancel") { dismiss() }
          .buttonStyle(.bordered)
          .tint(Color.spPrimary.opacity(0.3))
        Spacer()
        Button("Save Class") { save() }
          .buttonStyle(.borderedProminent)
          .tint(Color.spPrimary)
          .disabled(className.isEmpty || days.isEmpty)
      }
      .padding(.top, 8)
    }
  }

  // uses shared choicePill defined at file scope

  private func toggleDay(_ d: String) { if days.contains(d) { days.remove(d) } else { days.insert(d) } }

  private func save() { 
    let rec = ClassRecord(
      mode: mode, 
      className: className, 
      room: room, 
      building: building, 
      teacher: teacher, 
      days: Array(days).sorted(), 
      startTime: startTime, 
      endTime: endTime,
      startDate: startDate,
      endDate: endDateValue
    )
    context.insert(rec)
    try? context.save()
    dismiss()
  }
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

