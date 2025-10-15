//
//  EventListView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 10/12/25.
//

import SwiftUI

struct EventListView: View {
    let events: [EventItem]

    private var grouped: [(date: Date, items: [EventItem])] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 7, to: start)!

        let days: [Date] = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
        let windowEvents = events.filter { item in
            let d = cal.startOfDay(for: item.date)
            return d >= start && d < end
        }
        let groups = Dictionary(grouping: windowEvents) { item in
            cal.startOfDay(for: item.date)
        }
        return days.map { day in
            let items = (groups[day] ?? []).sorted { $0.startTime < $1.startTime }
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
                                Text("No events")
                                    .font(.subheadline)
                                    .foregroundColor(.black.opacity(0.6))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                            } else {
                                ForEach(bucket.items) { item in
                                    EventRow(item: item)
                                        .padding(.horizontal)
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

private struct EventRow: View {
    let item: EventItem

    var body: some View {
        NavigationLink(destination: EventDetailView(event: item)) {
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
                    Text(timeRange(item))
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                }

                Spacer()

                Text(shortDate(item.date))
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
        .buttonStyle(.plain)
    }

    private func icon(for type: EventType) -> String {
        switch type {
        case .classSession: return "🎓"
        case .interview:    return "💼"
        case .coffeeChat:   return "☕️"
        case .campusEvent:  return "🎉"
        case .exam:         return "🧪"
        case .holiday:      return "🏖"
        }
    }

    private func color(for type: EventType) -> Color {
        switch type {
        case .classSession: return .blue
        case .interview:    return .green
        case .coffeeChat:   return .orange
        case .campusEvent:  return .purple
        case .exam:         return .red
        case .holiday:      return .teal
        }
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    private func timeRange(_ item: EventItem) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return "\(f.string(from: item.startTime)) – \(f.string(from: item.endTime))"
    }
}


struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EventListView(events: EventItem.sampleData())
        }
    }
}


