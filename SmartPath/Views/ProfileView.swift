//
//  ProfileView 2.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/11/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var vm: ProfileViewModel

    init(context: ModelContext) {
        _vm = StateObject(wrappedValue: ProfileViewModel(context: context))
      }

    var body: some View {
            NavigationStack {
                ZStack {
                    GradientBackground()
                        .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        // Photo
                        if let img = vm.student.photo {
                            img
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 60))
                                .foregroundColor(Color.spSecondary)
                                )
                        }

                        // Info rows
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(label: "Student ID", value: vm.student.studentID)
                            InfoRow(label: "Name",       value: vm.student.name)
                            InfoRow(label: "Year",       value: vm.student.schoolYear)
                            InfoRow(label: "Term",       value: vm.student.term)
                            InfoRow(label: "GPA",        value: String(format: "%.2f", vm.student.gpa))
                        }
                        .padding(.horizontal)

                        // Cards row
                        HStack(spacing: 12) {
                            NavigationLink(destination: TaskListView(tasks: TaskItem.sampleData())) {
                              StatCardButton(
                                emoji: "👀",
                                title: "Pending Tasks",
                                count: 3,
                                subtitle: "Next 7 days",
                                gradientColors: [
                                    Color.spPrimary.opacity(0.15),
                                    Color.white.opacity(0.7)
                                ],
                                countColor: Color.spPrimary
                              )
                            }

                            NavigationLink(destination: EventListView(events: EventItem.sampleData())) {
                              StatCardButton(
                                emoji: "📅",
                                title: "Upcoming Events",
                                count: 4,
                                subtitle: "Next 7 days",
                                gradientColors: [
                                    Color.spSecondary.opacity(0.15),
                                    Color.white.opacity(0.7)
                                ],
                                countColor: Color.spSecondary
                              )
                            }
                        }
                        .padding(.horizontal)

                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { vm.startEditing() } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.black)
                        }
                    }
                }
                .sheet(isPresented: $vm.isEditing) {
                    EditProfileView(viewModel: vm)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80)
                }
            }
        }
    }

    private struct InfoRow: View {
        let label: String, value: String
        var body: some View {
            HStack {
                Text(label)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
                Text(value)
                    .foregroundColor(.black.opacity(0.8))
            }
            .padding(.vertical, 4)
        }
    }
