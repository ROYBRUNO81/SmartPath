//
//  ProfileViewModel.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/7/25.
//

import SwiftUI
import SwiftData

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var student: Student
    
    // Editable drafts - Give default values to fix initialization error
    @Published var draftID: String = ""
    @Published var draftName: String = ""
    @Published var draftYear: String = ""
    @Published var draftTerm: String = ""
    @Published var draftGPA: String = ""
    @Published var draftPhotoData: Data? = nil
    @Published var draftImage: Image? = nil

    @Published var isEditing = false

    private let context: ModelContext

    init(context: ModelContext) {
        // Initialize context first
        self.context = context
        
        // Initialize student property
        if let existingStudent = try? context.fetch(FetchDescriptor<Student>()).first {
            self.student = existingStudent
        } else {
            let newStudent = Student(
                studentID: UUID().uuidString,
                name: "",
                schoolYear: "",
                term: "",
                gpa: 0,
                photoData: nil,
                major: Major(name: "", requiredCourses: [], creditRequired: 0),
                schedule: Schedule()
            )
            context.insert(newStudent)
            self.student = newStudent
        }

        // Now all stored properties are initialized, so we can call methods
        self.populateDrafts()
    }
    
    private func populateDrafts() {
        draftID = student.studentID
        draftName = student.name
        draftYear = student.schoolYear
        draftTerm = student.term
        draftGPA = String(student.gpa)
        draftPhotoData = student.photoData
        
        if let data = student.photoData, let uiImage = UIImage(data: data) {
            draftImage = Image(uiImage: uiImage)
        } else {
            draftImage = nil
        }
    }

    func startEditing() {
        isEditing = true
    }

    func cancel() {
        // Revert drafts - now we can call the helper method
        populateDrafts()
        isEditing = false
    }

    func save() {
        // Commit drafts
        student.studentID = draftID
        student.name = draftName
        student.schoolYear = draftYear
        student.term = draftTerm
        student.gpa = Double(draftGPA) ?? student.gpa
        student.photoData = draftPhotoData
        
        try? context.save()
        isEditing = false
    }
}


