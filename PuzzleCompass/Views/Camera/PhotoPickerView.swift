import SwiftUI
import PhotosUI

/// View for selecting photos from the library
struct PhotoPickerView: View {
    // App state for managing navigation and data
    @EnvironmentObject var appState: AppState
    
    // Environment values
    @Environment(\.presentationMode) var presentationMode
    
    // State for photo picker
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showAlert = false
    
    // Shared limit for photo selection
    let MAX_SELECTION: Int = 10
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                Text("Select Puzzle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Spacer()
                
                // Photo picker
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: appState.cameraMode == .puzzle ? 1 : MAX_SELECTION,
                    matching: .images,
                    preferredItemEncoding: .compatible,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.1))
                            .frame(maxWidth: .infinity, maxHeight: 200)
                        
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 48))
                                .foregroundColor(.blue)
                            
                            Text(appState.cameraMode == .puzzle ? "Select Complete Puzzle" : "Select Puzzle Pieces")
                                .font(.title3)
                                .foregroundColor(.primary)
                            
                            Text(appState.cameraMode == .puzzle ? "Choose 1 image" : "Choose up to \(MAX_SELECTION) images")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                // Status and error message
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // Selected items info
                if !selectedItems.isEmpty {
                    Text("\(selectedItems.count) \(selectedItems.count == 1 ? "image" : "images") selected")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
                
                // Action buttons
                HStack {
                    // Cancel button
                    Button(action: {
                        print("Cancel button tapped")
                        // Use appState navigation instead of UIKit dismiss
                        appState.navigateToMainScreen()
                    }) {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    
                    // Confirm button
                    Button(action: {
                        processSelectedImages()
                    }) {
                        Text("Confirm")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedItems.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(selectedItems.isEmpty)
                }
                .padding()
            }
            .padding()
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage ?? "An unknown error occurred"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onChange(of: selectedItems) { _ in
            errorMessage = nil
        }
    }
    
    // Process the selected images
    private func processSelectedImages() {
        isLoading = true
        
        // Verify selected items count based on mode
        if appState.cameraMode == .puzzle && selectedItems.count != 1 {
            errorMessage = "Please select exactly 1 complete puzzle image"
            showAlert = true
            isLoading = false
            return
        } else if appState.cameraMode == .piece && selectedItems.isEmpty {
            errorMessage = "Please select at least one puzzle piece image"
            showAlert = true
            isLoading = false
            return
        }
        
        // Create a task group to load images in parallel
        Task {
            var loadedImages: [UIImage] = []
            
            for item in selectedItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    loadedImages.append(image)
                }
            }
            
            // Update the app state with the loaded images on the main thread
            await MainActor.run {
                isLoading = false
                
                if loadedImages.isEmpty {
                    errorMessage = "Failed to load selected images"
                    showAlert = true
                    return
                }
                
                // Process images based on camera mode
                if appState.cameraMode == .puzzle {
                    guard let puzzleImage = loadedImages.first else { return }
                    appState.setPuzzleImage(puzzleImage)
                    appState.navigateToConfirmation(source: .album)
                } else {
                    // Add each piece image
                    for image in loadedImages {
                        appState.addPieceImage(image)
                    }
                    appState.navigateToConfirmation(source: .album)
                }
                
                // Dismiss this view
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
} 