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
                                        .foregroundColor(.secondary)
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

                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { vm.startEditing() } label: {
                            Image(systemName: "pencil")
                                .foregroundColor(.white)
                        }
                    }
                }
                .sheet(isPresented: $vm.isEditing) {
                    EditProfileView(viewModel: vm)
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
                    .foregroundColor(.white)
                Spacer()
                Text(value)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.vertical, 4)
        }
    }
