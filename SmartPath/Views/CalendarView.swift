//
//  CalendarView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/11/25.
//

import SwiftUI
import Combine
import SwiftData

struct PlannerCalendarView: View {
    @StateObject private var vm = CalendarViewModel()
    @Environment(\.modelContext) private var context
    @State private var refreshTrigger = false

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
                        DayView(anchor: vm.anchorDate, displayEvents: vm.fetchDisplayEvents(for: vm.anchorDate))
                            .id("\(vm.anchorDate.timeIntervalSince1970)-\(refreshTrigger)")
                    case .week:
                        WeekView(anchor: vm.anchorDate, events: vm.visibleEvents(in: weekInterval))
                    case .month:
                        MonthView(anchor: vm.anchorDate, events: vm.visibleEvents(in: monthInterval))
                    }
                }

                if vm.showMenu { SideFilterMenu(vm: vm) }
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
            .onAppear {
                vm.setContext(context)
                refreshTrigger.toggle()
            }
            .onChange(of: vm.anchorDate) { _, _ in
                refreshTrigger.toggle()
            }
            .onChange(of: vm.showTasks) { _, _ in
                refreshTrigger.toggle()
            }
            .onChange(of: vm.showClasses) { _, _ in
                refreshTrigger.toggle()
            }
            .onChange(of: vm.showExams) { _, _ in
                refreshTrigger.toggle()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshCalendar"))) { _ in
                refreshTrigger.toggle()
            }
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
                    .foregroundColor(Color(hex: "#3D8B7D"))
                    .padding(16)
                    .background(Color.white.opacity(0.7))
                    .clipShape(Circle())
            }

            Spacer()

            HStack(spacing: 8) {
                Button { vm.previous() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "#3D8B7D"))
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
                        .foregroundColor(Color(hex: "#3D8B7D"))
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                }
            }
            Spacer()

            Button("Today") { vm.goToday() }
                .foregroundColor(Color(hex: "#3D8B7D"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule().stroke(Color(hex: "#3D8B7D"), lineWidth: 2)
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
    let displayEvents: [DisplayEvent]
    @State private var now: Date = Date()
    private let hourRowHeight: CGFloat = 56
    private let labelColumnWidth: CGFloat = 64 // label (56) + left padding (8)
    private let topInsetForDayBadge: CGFloat = 52

    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                hourGrid
                    .padding(.top, topInsetForDayBadge)
                eventsOverlay
                    .padding(.top, topInsetForDayBadge)
                if isToday {
                    currentTimeIndicator
                        .offset(y: topInsetForDayBadge)
                }
                dayBadge
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
                HStack(alignment: .top, spacing: 0) {
                    // Hour label aligned to the start of the hour (row top)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(hourLabel(h))
                            .foregroundColor(.black.opacity(0.55))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                    .frame(width: 56)
                    .padding(.leading, 8)

                    // Events pane filler
                    Rectangle().fill(Color.clear)
                    Spacer(minLength: 0)
                }
                .frame(height: hourRowHeight)
                // Faint separator placed at the top of the row (start of the hour), only across events pane
                .overlay(alignment: .topLeading) {
                    HStack(spacing: 0) {
                        Spacer().frame(width: labelColumnWidth)
                        Rectangle()
                            .fill(Color.spSecondary.opacity(0.05))
                            .frame(height: 1)
                    }
                }
            }
        }
        // Vertical separator between labels and events area
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Color(hex: "#2C5F54").opacity(0.08))
                .frame(width: 1)
                .offset(x: labelColumnWidth)
        }
    }

    private var currentTimeIndicator: some View {
        let y = CGFloat(minutesIntoDay()) / 60.0 * hourRowHeight
        let startX: CGFloat = labelColumnWidth // dot center on the vertical separator
        return ZStack(alignment: .topLeading) {
            // Line from dot center to the right only
            HStack(spacing: 0) {
                Spacer().frame(width: startX)
                Rectangle()
                    .fill(Color(hex: "#3D8B7D"))
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(y: y)

            // Dot
            Circle()
                .fill(Color(hex: "#3D8B7D"))
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

    private var dayBadge: some View {
        let cal = Calendar.current
        let weekday = DateFormatter.localizedString(from: anchor, dateStyle: .full, timeStyle: .none)
        let shortWeek = weekday.components(separatedBy: ",").first?.prefix(3).uppercased() ?? "TOD"
        let dayNum = cal.component(.day, from: anchor)
        return VStack(spacing: 6) {
            Text(shortWeek)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "#2C5F54"))
            Text("\(dayNum)")
                .font(.headline)
                .foregroundColor(isToday ? .white : Color(hex: "#3D8B7D"))
                .frame(width: 30, height: 30)
                .background(
                    Circle().fill(isToday ? Color(hex: "#3D8B7D") : Color.clear)
                )
                .overlay(
                    Circle().stroke(Color(hex: "#3D8B7D"), lineWidth: 2)
                )
        }
        .frame(width: 56, alignment: .center)
        .offset(x: 4, y: -2)
    }
    
    private var eventsOverlay: some View {
        GeometryReader { geometry in
            ForEach(displayEvents) { event in
                EventCard(event: event)
                    .offset(x: labelColumnWidth + 4, y: yOffset(for: event.startTime))
                    .frame(width: geometry.size.width - labelColumnWidth - 8, height: eventHeight(event))
            }
        }
    }
    
    private func yOffset(for time: Date) -> CGFloat {
        let cal = Calendar.current
        let components = cal.dateComponents([.hour, .minute], from: time)
        let hour = CGFloat(components.hour ?? 0)
        let minute = CGFloat(components.minute ?? 0)
        return (hour * hourRowHeight) + (minute / 60.0 * hourRowHeight)
    }
    
    private func eventHeight(_ event: DisplayEvent) -> CGFloat {
        let duration = event.endTime.timeIntervalSince(event.startTime)
        let hours = duration / 3600.0
        return CGFloat(hours) * hourRowHeight
    }
}

private struct EventCard: View {
    let event: DisplayEvent
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(event.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                        Text(event.type)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(typeColor(event.type))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(typeColor(event.type).opacity(0.15))
                            .cornerRadius(4)
                    }
                    if !event.subtitle.isEmpty {
                        Text(event.subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(hex: event.colorHex).opacity(0.25))
            .overlay(
                Rectangle()
                    .fill(Color(hex: event.colorHex))
                    .frame(width: 4),
                alignment: .leading
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if let task = event.originalRecord as? TaskRecord {
            TaskDetailView(task: task)
        } else if let classRecord = event.originalRecord as? ClassRecord {
            ClassDetailView(classRecord: classRecord)
        } else if let exam = event.originalRecord as? ExamRecord {
            ExamDetailView(exam: exam)
        } else {
            Text("Event Details")
                .navigationTitle("Event")
        }
    }
    
    private func typeColor(_ type: String) -> Color {
        switch type {
        case "Class": return Color(hex: "#9B59B6")
        case "Task": return Color(hex: "#3498DB")
        case "Exam": return Color(hex: "#1ABC9C")
        default: return Color.gray
        }
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
                // Header with close button
                HStack {
                    Text("Calendar Filters")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { withAnimation { vm.showMenu = false } }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 8)
                
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
                   .gesture(
                       DragGesture()
                           .onEnded { value in
                               // Swipe left to close
                               if value.translation.width < -50 {
                                   withAnimation { vm.showMenu = false }
                               }
                           }
                   )

            // Tap area to close menu
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { vm.showMenu = false } }
        }
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
            .background(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#3D8B7D"), lineWidth: selected ? 2 : 1).opacity(0.5))
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
                    .foregroundColor(Color(hex: "#3D8B7D"))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.4)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#3D8B7D").opacity(0.5), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}
