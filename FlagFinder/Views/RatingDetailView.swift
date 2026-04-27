//
//  RatingDetailView.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import SwiftUI
import MapKit
import FirebaseFirestore
import PhotosUI

struct RatingDetailView: View {
    var rating: CourseRating
    @FirestoreQuery var photos: [CoursePhoto]
    @State private var showRatingSheet = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var newPhoto = CoursePhoto()
    @State private var imageData = Data()
    
    init(rating: CourseRating) {
        self.rating = rating
        _photos = FirestoreQuery(collectionPath: "ratings/\(rating.id ?? "")/photos")
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: rating.latitude, longitude: rating.longitude)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                Map {
                    Marker(rating.courseName, coordinate: coordinate)
                        .tint(Color("flagDarkGreen"))
                }
                .frame(height: 200)
                .mapControls {
                    MapScaleView()
                    MapUserLocationButton()
                    MapCompass()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", rating.score))
                            .font(.system(size: 52, weight: .semibold))
                            .foregroundStyle(Color("flagDarkGreen"))
                        Text("/ 10")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(rating.tierLabel + " Tier")
                            .font(.headline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color("flagLightGreen"))
                            .foregroundStyle(Color("flagDarkGreen"))
                            .clipShape(Capsule())
                    }
                    
                    if !rating.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(rating.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color("flagLightGreen"))
                                        .foregroundStyle(Color("flagDarkGreen"))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    if !rating.note.isEmpty {
                        Text("\"\(rating.note)\"")
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Photos")
                            .font(.headline)
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                                .foregroundStyle(Color("flagDarkGreen"))
                        }
                    }
                    
                    if photos.isEmpty {
                        Text("No photos yet. Tap + to add one.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 100), spacing: 4)],
                            spacing: 4
                        ) {
                            ForEach(photos) { photo in
                                AsyncImage(url: URL(string: photo.imageURLString)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(rating.courseName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit Rating") {
                    showRatingSheet = true
                }
                .foregroundStyle(Color("flagDarkGreen"))
            }
        }
        .sheet(isPresented: $showRatingSheet) {
            RatingSheetView(
                courseName: rating.courseName,
                courseAddress: rating.courseAddress,
                courseId: rating.courseId,
                latitude: rating.latitude,
                longitude: rating.longitude,
                existingRating: rating
            )
        }
        .onChange(of: selectedPhoto) { oldValue, newValue in
            Task {
                do {
                    guard let data = try await selectedPhoto?.loadTransferable(type: Data.self) else {
                        return
                    }
                    imageData = data
                    newPhoto = CoursePhoto()
                    await CoursePhotoViewModel.saveImage(
                        rating: rating,
                        photo: newPhoto,
                        data: imageData
                    )
                    selectedPhoto = nil
                } catch {
                    print("ERROR: Could not load photo. \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RatingDetailView(rating: CourseRating.preview)
    }
}
