//
//  TaskListView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 10/12/25.
//

import SwiftUI

struct TaskListView: View {
    let tasks: [TaskItem]

    private var grouped: [(date: Date, items: [TaskItem])] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 7, to: start)!

        // Dates for the next 7 days
        let days: [Date] = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }

        // Only include tasks in the next 7 days window
        let windowTasks = tasks.filter { item in
            let d = cal.startOfDay(for: item.dueDate)
            return d >= start && d < end
        }

        let groups = Dictionary(grouping: windowTasks) { item in
            cal.startOfDay(for: item.dueDate)
        }

        return days.map { day in
            let items = (groups[day] ?? []).sorted { $0.dueTime < $1.dueTime }
            return (day, items)
        }
    }

    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                    ForEach(grouped, id: \.date) { bucket in
                        Section(header: header(bucket.date, count: bucket.items.count)) {
                            if bucket.items.isEmpty {
                                Text("No tasks")
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.6))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            } else {
                                ForEach(bucket.items) { item in
                                    TaskRow(item: item)
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

private struct TaskRow: View {
    let item: TaskItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(color(for: item.type).opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(icon(for: item.type))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
            }

            Spacer()

            Text(timeString(item.dueTime))
                .font(.headline)
                .foregroundColor(.black)
        }
        .padding(14)
        .background(
            LinearGradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)], startPoint: .top, endPoint: .bottom)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func icon(for type: TaskType) -> String {
        switch type {
        case .assignment: return "📚"
        case .reminder:   return "⏰"
        case .essay:      return "📝"
        }
    }

    private func color(for type: TaskType) -> Color {
        switch type {
        case .assignment: return .blue
        case .reminder:   return .orange
        case .essay:      return .pink
        }
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TaskListView(tasks: TaskItem.sampleData())
        }
    }
}


