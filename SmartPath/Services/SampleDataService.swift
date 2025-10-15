//
//  SampleDataService.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 10/14/25.
//

import Foundation
import SwiftData

class SampleDataService {
    static func clearExistingData(context: ModelContext) {
        // Clear all existing data
        if let tasks = try? context.fetch(FetchDescriptor<TaskRecord>()) {
            for task in tasks { context.delete(task) }
        }
        if let classes = try? context.fetch(FetchDescriptor<ClassRecord>()) {
            for classRec in classes { context.delete(classRec) }
        }
        if let exams = try? context.fetch(FetchDescriptor<ExamRecord>()) {
            for exam in exams { context.delete(exam) }
        }
        if let streaks = try? context.fetch(FetchDescriptor<StreakRecord>()) {
            for streak in streaks { context.delete(streak) }
        }
        try? context.save()
    }
    
    static func populateSampleData(context: ModelContext) {
        // Clear existing data first (for testing)
        clearExistingData(context: context)
        
        // Create a default Major and Schedule
        let defaultMajor = Major(name: "Computer Science", requiredCourses: ["CIS120", "CIS121"], creditRequired: 32)
        let defaultSchedule = Schedule()
        context.insert(defaultMajor)
        context.insert(defaultSchedule)
        
        // Create a default Student
        let student = Student(
            firstName: "John",
            lastName: "Doe",
            email: "john.doe@upenn.edu",
            photoData: nil,
            major: defaultMajor,
            schedule: defaultSchedule
        )
        context.insert(student)
        
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        // Helper to create time
        func time(_ hour: Int, _ minute: Int) -> Date {
            cal.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? Date()
        }
        
        // Helper to add days
        func addDays(_ days: Int) -> Date {
            cal.date(byAdding: .day, value: days, to: today) ?? today
        }
        
        // SAMPLE TASKS
        
        // One-time tasks
        let task1 = TaskRecord(
            title: "CIS 1951 Homework 3",
            details: "Complete SwiftUI assignment on navigation and data modeling",
            occurs: "Once",
            dueDate: addDays(2),
            dueTime: time(23, 59)
        )
        
        let task2 = TaskRecord(
            title: "Biology Lab Report",
            details: "Write up results from last week's experiment on cell division",
            occurs: "Once",
            dueDate: addDays(5),
            dueTime: time(17, 0)
        )
        
        let task3 = TaskRecord(
            title: "Math Problem Set",
            details: "Chapter 8 problems 1-25, focus on integration techniques",
            occurs: "Once",
            dueDate: addDays(1),
            dueTime: time(11, 59)
        )
        
        // Repeating task
        let task4 = TaskRecord(
            title: "Weekly Reading Response",
            details: "Submit 500-word response to assigned reading",
            occurs: "Repeating",
            dueDate: today,
            dueTime: time(23, 59),
            days: ["Mon"],
            startDate: addDays(-7),
            endDate: addDays(60)
        )
        
        context.insert(task1)
        context.insert(task2)
        context.insert(task3)
        context.insert(task4)
        
        // SAMPLE CLASSES
        
        let class1 = ClassRecord(
            mode: "In Person",
            className: "CIS 1951 - iOS Development",
            room: "337",
            building: "Towne Building",
            teacher: "Prof. Johnson",
            days: ["Mon", "Wed"],
            startTime: time(10, 30),
            endTime: time(12, 0),
            startDate: addDays(-7),
            endDate: addDays(60)
        )
        
        let class2 = ClassRecord(
            mode: "In Person",
            className: "BIOL 101 - Introduction to Biology",
            room: "A6",
            building: "Leidy Labs",
            teacher: "Dr. Smith",
            days: ["Tue", "Thu"],
            startTime: time(13, 30),
            endTime: time(15, 0),
            startDate: addDays(-7),
            endDate: addDays(60)
        )
        
        let class3 = ClassRecord(
            mode: "Online",
            className: "MATH 240 - Calculus II",
            room: "",
            building: "",
            teacher: "Prof. Anderson",
            days: ["Mon", "Wed", "Fri"],
            startTime: time(9, 0),
            endTime: time(10, 0),
            startDate: addDays(-7),
            endDate: addDays(60)
        )
        
        let class4 = ClassRecord(
            mode: "In Person",
            className: "ENGL 102 - Critical Writing",
            room: "201",
            building: "Williams Hall",
            teacher: "Dr. Lee",
            days: ["Tue", "Thu"],
            startTime: time(10, 30),
            endTime: time(12, 0),
            startDate: addDays(-7),
            endDate: addDays(60)
        )
        
        // Add a class for tomorrow (Wednesday) that will show up
        let class5 = ClassRecord(
            mode: "In Person",
            className: "CIS 1951 - iOS Development",
            room: "337",
            building: "Towne Building",
            teacher: "Prof. Johnson",
            days: ["Wed"],
            startTime: time(10, 30),
            endTime: time(12, 0),
            startDate: addDays(1),
            endDate: addDays(1)
        )
        
        // Add a class for Thursday that will show up
        let class6 = ClassRecord(
            mode: "In Person",
            className: "BIOL 101 - Introduction to Biology",
            room: "A6",
            building: "Leidy Labs",
            teacher: "Dr. Smith",
            days: ["Thu"],
            startTime: time(13, 30),
            endTime: time(15, 0),
            startDate: addDays(2),
            endDate: addDays(2)
        )

        context.insert(class1)
        context.insert(class2)
        context.insert(class3)
        context.insert(class4)
        context.insert(class5)
        context.insert(class6)
        
        // SAMPLE EXAMS
        
        let exam1 = ExamRecord(
            name: "Midterm 1",
            examType: "Midterm 1",
            customType: "",
            mode: "In Person",
            room: "200",
            building: "Towne Building",
            link: "",
            date: addDays(7),
            time: time(14, 0),
            durationMinutes: 90
        )
        
        let exam2 = ExamRecord(
            name: "Biology Final Exam",
            examType: "Final",
            customType: "",
            mode: "In Person",
            room: "Hall A",
            building: "Houston Hall",
            link: "",
            date: addDays(45),
            time: time(9, 0),
            durationMinutes: 180
        )
        
        let exam3 = ExamRecord(
            name: "Math Midterm",
            examType: "Midterm 2",
            customType: "",
            mode: "Online",
            room: "",
            building: "",
            link: "https://zoom.us/j/123456789",
            date: addDays(21),
            time: time(13, 0),
            durationMinutes: 120
        )
        
        // Repeating quiz
        let quiz1 = ExamRecord(
            name: "Weekly Quiz",
            examType: "Quiz",
            customType: "",
            mode: "In Person",
            room: "337",
            building: "Towne Building",
            link: "",
            date: today,
            time: time(10, 30),
            durationMinutes: 15,
            isRepeating: true,
            days: ["Fri"],
            startDate: addDays(-14),
            endDate: addDays(56)
        )
        
        context.insert(exam1)
        context.insert(exam2)
        context.insert(exam3)
        context.insert(quiz1)
        
        // Save all
        try? context.save()
    }
}

