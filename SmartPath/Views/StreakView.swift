//
//  StreakView.swift
//  SmartPath
//
//  Created by Assistant on 10/14/25.
//

import SwiftUI
import SwiftData

struct StreakView: View {
    @Environment(\.modelContext) private var context
    @State private var refreshTrigger = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Streak Header
                        streakHeader
                        
                        // 14-Day History
                        historySection
                    }
                    .padding()
                }
            }
            .navigationTitle("Study Streak")
            .navigationBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshStreak"))) { _ in
                refreshTrigger.toggle()
            }
        }
    }
    
    private var streakHeader: some View {
        VStack(spacing: 16) {
            // Current Streak
            VStack(spacing: 8) {
                Text("\(currentStreak)")
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(Color.spPrimary)
                
                Text("Day Streak")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text("Keep it up! 🔥")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.spPrimary.opacity(0.3), lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Today's Progress
            if hasActivityToday {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Today's Goal Complete!")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    Text("You've already studied today. Great job!")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.green, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                        Text("Complete something today!")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    Text("Finish a task, take an exam, or do a pomodoro session to keep your streak alive.")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.orange, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Spacer()
            }
            
            if recentActivities.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 48))
                        .foregroundColor(.black.opacity(0.3))
                    
                    Text("No recent activity")
                        .font(.headline)
                        .foregroundColor(.black.opacity(0.6))
                    
                    Text("Complete tasks, exams, or pomodoro sessions to start building your streak!")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(recentActivities) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentStreak: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        // Get all unique dates with activities
        let allActivities = (try? context.fetch(FetchDescriptor<StreakRecord>())) ?? []
        let uniqueDates = Set(allActivities.map { cal.startOfDay(for: $0.date) }).sorted(by: >)
        
        // Count consecutive days from today backwards
        for date in uniqueDates {
            if cal.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = cal.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private var hasActivityToday: Bool {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let allActivities = (try? context.fetch(FetchDescriptor<StreakRecord>())) ?? []
        return allActivities.contains { cal.isDate($0.date, inSameDayAs: today) }
    }
    
    private var recentActivities: [StreakRecord] {
        let cal = Calendar.current
        let fourteenDaysAgo = cal.date(byAdding: .day, value: -14, to: cal.startOfDay(for: Date())) ?? Date()
        
        let allActivities = (try? context.fetch(FetchDescriptor<StreakRecord>())) ?? []
        return allActivities
            .filter { $0.date >= fourteenDaysAgo }
            .sorted { $0.completedAt > $1.completedAt }
    }
}

// MARK: - Activity Row

private struct ActivityRow: View {
    let activity: StreakRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // Activity Icon
            ZStack {
                Circle()
                    .fill(activityColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: activityIcon)
                    .foregroundColor(activityColor)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            // Activity Details
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.activityTitle)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(activity.activityDetails)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.6))
                
                Text(timeString(activity.completedAt))
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.5))
            }
            
            Spacer()
            
            // Activity Type Badge
            Text(activityTypeLabel)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(activityColor)
                .clipShape(Capsule())
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var activityColor: Color {
        switch activity.activityType {
        case "task": return .blue
        case "exam": return .green
        case "pomodoro": return .orange
        default: return .gray
        }
    }
    
    private var activityIcon: String {
        switch activity.activityType {
        case "task": return "checkmark.circle"
        case "exam": return "graduationcap"
        case "pomodoro": return "timer"
        default: return "circle"
        }
    }
    
    private var activityTypeLabel: String {
        switch activity.activityType {
        case "task": return "Task"
        case "exam": return "Exam"
        case "pomodoro": return "Study"
        default: return "Activity"
        }
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: date)
    }
}
