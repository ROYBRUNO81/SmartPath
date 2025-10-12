//
//  CalendarView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/11/25.
//

import SwiftUI
import Combine

struct PlannerCalendarView: View {
    @StateObject private var vm = CalendarViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground().ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                    switch vm.mode {
                    case .day:
                        DayView(anchor: vm.anchorDate, events: vm.visibleEvents(in: dayInterval), tasks: vm.visibleTasks(in: dayInterval))
                    case .week:
                        WeekView(anchor: vm.anchorDate, events: vm.visibleEvents(in: weekInterval))
                    case .month:
                        MonthView(anchor: vm.anchorDate, events: vm.visibleEvents(in: monthInterval))
                    }
                }

                if vm.showMenu { SideFilterMenu(vm: vm) }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var dayInterval: DateInterval {
        let start = Calendar.current.startOfDay(for: vm.anchorDate)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return DateInterval(start: start, end: end)
    }

    private var weekInterval: DateInterval {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: vm.anchorDate))!
        let end = cal.date(byAdding: .day, value: 7, to: start)!
        return DateInterval(start: start, end: end)
    }

    private var monthInterval: DateInterval {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: vm.anchorDate)
        let start = cal.date(from: comps)!
        let end = cal.date(byAdding: .month, value: 1, to: start)!
        return DateInterval(start: start, end: end)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { withAnimation { vm.showMenu.toggle() } } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.spPrimary)
                    .padding(16)
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }

            Spacer()

            HStack(spacing: 8) {
                Button { vm.previous() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.spPrimary)
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                }
                Text(monthYear(vm.anchorDate))
                    .font(.headline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.7))
                    )
                Button { vm.next() } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.spPrimary)
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                }
            }
            Spacer()

            Button("Today") { vm.goToday() }
                .foregroundColor(Color.spPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().stroke(Color.spPrimary, lineWidth: 2)
                )

        }
    }

    private func monthYear(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }
}

// MARK: - Day View (hour grid)

private struct DayView: View {
    let anchor: Date
    let events: [EventItem]
    let tasks: [TaskItem]
    @State private var now: Date = Date()
    private let hourRowHeight: CGFloat = 56

    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                hourGrid
                if isToday {
                    currentTimeIndicator
                }
            }
            .padding(.top, 8)
        }
        .background(Color.white.opacity(0.35))
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { date in
            now = date
        }
    }

    private var hourGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<24) { h in
                HStack {
                    Text(hourLabel(h))
                        .foregroundColor(.black.opacity(0.6))
                        .frame(width: 56, alignment: .leading)
                        .padding(.leading, 8)
                    Rectangle().fill(Color.clear)
                    Spacer(minLength: 0)
                }
                .frame(height: hourRowHeight)
                .overlay(
                    VStack { Spacer(); Divider().opacity(0.1) }
                )
            }
        }
    }

    private var currentTimeIndicator: some View {
        let y = CGFloat(minutesIntoDay()) / 60.0 * hourRowHeight
        let startX: CGFloat = 62 + 4 // align line start with dot center
        return ZStack(alignment: .topLeading) {
            // Line from dot center to the right only
            HStack(spacing: 0) {
                Spacer().frame(width: startX)
                Rectangle()
                    .fill(Color.spPrimary)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(y: y)

            // Dot
            Circle()
                .fill(Color.spPrimary)
                .frame(width: 8, height: 8)
                .offset(x: startX - 4, y: y - 4)
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        var h = hour % 24
        let ampm = h < 12 ? "AM" : "PM"
        h = h % 12
        if h == 0 { h = 12 }
        return "\(h) \(ampm)"
    }

    private func minutesIntoDay() -> Int {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: now)
        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0
        return hour * 60 + minute
    }

    private var isToday: Bool {
        Calendar.current.isDate(anchor, inSameDayAs: now)
    }
}

// MARK: - Week View (strip with weekday headers)

private struct WeekView: View {
    let anchor: Date
    let events: [EventItem]
    private let cal = Calendar.current

    var body: some View {
        VStack(spacing: 8) {
            weekdayHeader
            Rectangle().fill(Color.white.opacity(0.35)).frame(height: 1)
            Spacer()
        }
        .padding(.horizontal)
    }

    private var weekdayHeader: some View {
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: anchor))!
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
        return HStack {
            ForEach(days, id: \.self) { d in
                VStack {
                    Text(shortWeekday(d))
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                    Text(dayNumber(d))
                        .font(.headline)
                        .padding(6)
                        .background(Circle().fill(isSameDay(d, anchor) ? Color.spPrimary.opacity(0.25) : Color.clear))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func shortWeekday(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "E"; return f.string(from: d) }
    private func dayNumber(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "d"; return f.string(from: d) }
    private func isSameDay(_ a: Date, _ b: Date) -> Bool { cal.isDate(a, inSameDayAs: b) }
}

// MARK: - Month View (grid)

private struct MonthView: View {
    let anchor: Date
    let events: [EventItem]
    private let cal = Calendar.current

    var body: some View {
        VStack(spacing: 8) {
            monthGrid
                .padding(.horizontal)
            Spacer(minLength: 0)
        }
    }

    private var monthGrid: some View {
        let comps = cal.dateComponents([.year, .month], from: anchor)
        let start = cal.date(from: comps)!
        let firstWeekday = cal.component(.weekday, from: start)
        let range = cal.range(of: .day, in: .month, for: start)!
        let daysCount = range.count
        let leading = (firstWeekday + 6) % 7 // convert to Monday-first if desired
        let total = leading + daysCount
        let rows = Int(ceil(Double(total) / 7.0))

        return VStack(spacing: 8) {
            // Weekday row
            HStack {
                ForEach(["M","T","W","T","F","S","S"], id: \.self) { w in
                    Text(w).frame(maxWidth: .infinity).foregroundColor(.black.opacity(0.6))
                }
            }
            ForEach(0..<rows, id: \.self) { r in
                HStack(spacing: 8) {
                    ForEach(0..<7, id: \.self) { c in
                        let idx = r * 7 + c
                        let dayNum = idx - leading + 1
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.3))
                            if dayNum >= 1 && dayNum <= daysCount {
                                VStack(alignment: .leading) {
                                    Text("\(dayNum)")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .padding(4)
                                    Spacer(minLength: 12)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            }
                        }
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Side Filter Menu

private struct SideFilterMenu: View {
    @ObservedObject var vm: CalendarViewModel

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    modeRow(icon: "calendar", text: "Day", selected: vm.mode == .day) { vm.mode = .day }
                    modeRow(icon: "calendar", text: "Week", selected: vm.mode == .week) { vm.mode = .week }
                    modeRow(icon: "calendar", text: "Month", selected: vm.mode == .month) { vm.mode = .month }
                }
                Divider()
                filterRow(color: .green, label: "Classes", isOn: $vm.showClasses)
                filterRow(color: .purple, label: "Exams", isOn: $vm.showExams)
                filterRow(color: .teal, label: "Tasks", isOn: $vm.showTasks)
                filterRow(color: .orange, label: "Holidays", isOn: $vm.showHolidays)
                filterRow(color: .green, label: "Interviews", isOn: $vm.showInterviews)
                filterRow(color: .orange, label: "Coffee Chats", isOn: $vm.showCoffeeChats)
                Spacer()
            }
            .frame(width: 280)
            .padding()
            .background(.ultraThinMaterial)
            .transition(.move(edge: .leading))

            Spacer()
        }
        .onTapGesture { withAnimation { vm.showMenu = false } }
    }

    private func modeRow(icon: String, text: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(text)
                Spacer()
                if selected { Image(systemName: "checkmark") }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.spPrimary, lineWidth: selected ? 2 : 1).opacity(0.5))
        }
        .buttonStyle(.plain)
    }

    private func filterRow(color: Color, label: String, isOn: Binding<Bool>) -> some View {
        Button(action: { isOn.wrappedValue.toggle() }) {
            HStack {
                Circle().fill(color.opacity(0.6)).frame(width: 20, height: 20)
                Text(label)
                Spacer()
                Image(systemName: isOn.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(Color.spPrimary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.4)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spPrimary.opacity(0.5), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}
