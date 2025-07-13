//
//  Student.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import SwiftUI
import SwiftData
import UIKit

@Model
class Student {
  @Attribute(.unique) var studentID: String
  var name: String
  var schoolYear: String
  var term: String
  var gpa: Double
    
  @Attribute(.externalStorage) var photoData: Data?

  var major: Major
  var schedule: Schedule

  init(
    studentID: String,
    name: String,
    schoolYear: String,
    term: String,
    gpa: Double,
    photoData: Data? = nil,
    major: Major,
    schedule: Schedule
  ) {
    self.studentID  = studentID
    self.name       = name
    self.schoolYear = schoolYear
    self.term       = term
    self.gpa        = gpa
    self.photoData  = photoData
    self.major      = major
    self.schedule   = schedule
  }

  /// Convert stored Data into SwiftUI Image
  var photo: Image? {
    guard let data = photoData, let ui = UIImage(data: data) else { return nil }
    return Image(uiImage: ui)
  }
}
