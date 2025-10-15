//
//  OnboardingView.swift
//  SmartPath
//
//  Created by Assistant on 10/14/25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var showingMainApp = false
    
    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Welcome Section
                VStack(spacing: 16) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color.spPrimary)
                    
                    Text("Welcome to SmartPath")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Text("Let's get started by setting up your profile")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                
                // Form Section
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.black)
                        
                        TextField("Enter your first name", text: $firstName)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.black)
                        
                        TextField("Enter your last name", text: $lastName)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.black)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Continue Button
                Button(action: createStudentProfile) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.spPrimary : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isFormValid)
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $showingMainApp) {
            ContentView()
        }
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        email.contains("@")
    }
    
    private func createStudentProfile() {
        // Create default Major and Schedule
        let defaultMajor = Major(name: "Computer Science", requiredCourses: ["CIS120", "CIS121"], creditRequired: 32)
        let defaultSchedule = Schedule()
        
        // Create Student
        let student = Student(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            major: defaultMajor,
            schedule: defaultSchedule
        )
        
        // Insert into context
        context.insert(defaultMajor)
        context.insert(defaultSchedule)
        context.insert(student)
        
        // Save and show main app
        try? context.save()
        showingMainApp = true
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.8))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.1), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    OnboardingView()
        .modelContainer(try! ModelContainer(for: Student.self, Major.self, Schedule.self))
}
