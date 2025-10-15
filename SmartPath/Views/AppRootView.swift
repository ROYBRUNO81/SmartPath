//
//  AppRootView.swift
//  SmartPath
//
//  Created by Assistant on 10/14/25.
//

import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var context
    @Query private var students: [Student]
    
    var body: some View {
        Group {
            if students.isEmpty {
                OnboardingView()
            } else {
                ContentView()
            }
        }
    }
}

#Preview {
    AppRootView()
        .modelContainer(try! ModelContainer(for: Student.self, Major.self, Schedule.self))
}
