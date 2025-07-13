//
//  EditProfileView.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/11/25.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingImagePicker = false
    @State private var rawUIImage: UIImage?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        ZStack {
                            if let img = viewModel.draftImage {
                                img
                                  .resizable()
                                  .scaledToFill()
                                  .frame(width: 100, height: 100)
                                  .clipShape(Circle())
                            } else {
                                Circle()
                                  .fill(Color.secondary.opacity(0.3))
                                  .frame(width: 100, height: 100)
                                  .overlay(
                                    Image(systemName: "camera.fill")
                                      .font(.system(size: 40))
                                      .foregroundColor(.secondary)
                                  )
                            }
                        }
                        .onTapGesture { showingImagePicker = true }
                        Spacer()
                    }
                    .padding(.vertical)

                    TextField("Student ID", text: $viewModel.draftID)
                    TextField("Name",       text: $viewModel.draftName)
                    TextField("Year",       text: $viewModel.draftYear)
                    TextField("Term",       text: $viewModel.draftTerm)
                    TextField("GPA",        text: $viewModel.draftGPA)
                      .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("Cancel") { viewModel.cancel() }
                          .buttonStyle(.bordered)
                          .tint(.red.opacity(0.2))

                        Spacer()

                        Button("Save") { viewModel.save() }
                          .buttonStyle(.borderedProminent)
                          .tint(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $rawUIImage)
            }
        }
    }

    private func loadImage() {
        guard let ui = rawUIImage,
              let data = ui.jpegData(compressionQuality: 0.8)
        else { return }
        viewModel.draftPhotoData = data
        viewModel.draftImage = Image(uiImage: ui)
    }
}
