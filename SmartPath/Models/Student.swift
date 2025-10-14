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
  var firstName: String
  var lastName: String
  var email: String
    
  @Attribute(.externalStorage) var photoData: Data?

  var major: Major
  var schedule: Schedule

  init(
    firstName: String,
    lastName: String,
    email: String,
    photoData: Data? = nil,
    major: Major,
    schedule: Schedule
  ) {
    self.firstName  = firstName
    self.lastName   = lastName
    self.email      = email
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
