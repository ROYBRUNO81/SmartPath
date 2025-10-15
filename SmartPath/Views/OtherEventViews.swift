//
//  OtherEventViews.swift
//  SmartPath
//
//  Created by Assistant on 10/14/25.
//

import SwiftUI
import SwiftData

// MARK: - Other Event Category View
struct OtherEventCategoryView: View {
    let context: ModelContext
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            SwipeableTabView(tabs: ["Current", "Past"], selectedIndex: $selectedTab) { index in
                if index == 0 {
                    CurrentOtherEventView(context: context)
                } else {
                    PastOtherEventView(context: context)
                }
            }
        }
        .navigationTitle("Other Events")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Current Other Event View
struct CurrentOtherEventView: View {
    let context: ModelContext
    @State private var daysShown = 7
    
    private var grouped: [(date: Date, items: [OtherEventRecord])] {
        guard let allEvents = try? context.fetch(FetchDescriptor<OtherEventRecord>()) else { return [] }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: daysShown, to: start)!
        
        var dateMap: [Date: [OtherEventRecord]] = [:]
        
        for event in allEvents {
            let eventDate = cal.startOfDay(for: event.date)
            if eventDate >= start && eventDate < end {
                if dateMap[eventDate] == nil { dateMap[eventDate] = [] }
                dateMap[eventDate]?.append(event)
            }
        }
        
        return dateMap.map { (date: $0.key, items: $0.value.sorted { $0.time < $1.time }) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                    if grouped.isEmpty {
                        Text("No upcoming events")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                            .padding()
                    } else {
                        ForEach(grouped, id: \.date) { bucket in
                            Section(header: header(bucket.date, count: bucket.items.count)) {
                                ForEach(bucket.items, id: \.self) { item in
                                    OtherEventRow(event: item)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Other Events")
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

// MARK: - Past Other Event View
struct PastOtherEventView: View {
    let context: ModelContext
    @State private var daysShown = 14
    
    private var grouped: [(date: Date, items: [OtherEventRecord])] {
        guard let allEvents = try? context.fetch(FetchDescriptor<OtherEventRecord>()) else { return [] }
        let cal = Calendar.current
        let now = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -daysShown, to: now) ?? now
        
        var dateMap: [Date: [OtherEventRecord]] = [:]
        
        for event in allEvents {
            let eventDate = cal.startOfDay(for: event.date)
            if eventDate >= start && eventDate < now {
                if dateMap[eventDate] == nil { dateMap[eventDate] = [] }
                dateMap[eventDate]?.append(event)
            }
        }
        
        return dateMap.map { (date: $0.key, items: $0.value.sorted { $0.time < $1.time }) }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                    if grouped.isEmpty {
                        Text("No past events")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                            .padding()
                    } else {
                        ForEach(grouped, id: \.date) { bucket in
                            Section(header: header(bucket.date, count: bucket.items.count)) {
                                ForEach(bucket.items, id: \.self) { item in
                                    OtherEventRow(event: item)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Past Events")
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

// MARK: - Other Event Row
struct OtherEventRow: View {
    let event: OtherEventRecord
    
    var body: some View {
        NavigationLink(destination: OtherEventDetailView(event: event)) {
            HStack {
                Circle()
                    .fill(Color(hex: event.colorHex))
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(event.eventType == "Other" ? event.customType : event.eventType)
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text(timeString(event.time))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
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
    
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

// MARK: - Other Event Detail View
struct OtherEventDetailView: View {
    let event: OtherEventRecord
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
                                    .fill(Color(hex: event.colorHex))
                                    .frame(width: 12, height: 12)
                                
                                Text(event.title)
                                    .font(.title2.weight(.semibold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            if !event.details.isEmpty {
                                HStack {
                                    Text(event.details)
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
                            DetailRow(title: "Type", value: event.eventType == "Other" ? event.customType : event.eventType)
                            DetailRow(title: "Mode", value: event.mode)
                            DetailRow(title: "Date", value: dateString(event.date))
                            DetailRow(title: "Time", value: timeString(event.time))
                            DetailRow(title: "Duration", value: "\(event.durationMinutes) minutes")
                            
                            if event.mode == "Online" && !event.location.isEmpty {
                                DetailRow(title: "Link", value: event.location)
                            } else if event.mode == "In Person" && !event.location.isEmpty {
                                DetailRow(title: "Location", value: event.location)
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
                                Text("Delete Event")
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
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .alert("Delete Event", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                context.delete(event)
                try? context.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this event? This action cannot be undone.")
        }
    }
    
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
