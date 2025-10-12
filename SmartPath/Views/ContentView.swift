//
//  ContentView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  enum Tab { case home, calendar, menu, profile }

  @State private var selection: Tab = .home
  @State private var showingAdd = false
  @Environment(\.modelContext) private var context

  var body: some View {
    ZStack {
      Group {
        switch selection {
        case .home:     HomeView()
        case .calendar: PlannerCalendarView()
        case .menu:     MenuView()
        case .profile:  ProfileView(context: context)
        }
      }
      .edgesIgnoringSafeArea(.all)

      VStack {
        Spacer()
        HStack {
          TabButton(system: "house.fill",   isSelected: selection == .home) {
            selection = .home
          }
          Spacer()

          TabButton(system: "calendar",     isSelected: selection == .calendar) {
            selection = .calendar
          }
          Spacer()

          Button(action: { showingAdd = true }) {
            Image(systemName: "plus.circle.fill")
              .resizable()
              .frame(width: 56, height: 56)
              .foregroundColor(Color.spPrimary)
              .background(Color(.systemBackground).clipShape(Circle()))
              .offset(y: -20)
          }
          .sheet(isPresented: $showingAdd) {
            Text("Add…")
              .font(.largeTitle)
              .padding()
          }
          Spacer()

          TabButton(system: "list.dash",   isSelected: selection == .menu) {
            selection = .menu
          }
          Spacer()

          TabButton(system: "person.crop.circle", isSelected: selection == .profile) {
            selection = .profile
          }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .background(BlurView(style: .systemMaterial))
      }
    }
  }
}

struct TabButton: View {
  let system: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: system)
        .font(.system(size: 24))
        .foregroundColor(isSelected ? Color.spPrimary : Color.spPrimary.opacity(0.5))
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .modelContainer(
        try! ModelContainer(
          for: Student.self,
          Major.self,
          Course.self,
          Schedule.self
        )
      )
  }
}

