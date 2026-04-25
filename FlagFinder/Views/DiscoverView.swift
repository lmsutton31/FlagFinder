import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

struct DiscoverView: View {
    let locationManager: LocationManager
    @State private var searchVM = GolfCourseSearchViewModel()
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var searchRegion = MKCoordinateRegion()
    @State private var selectedCourse: GolfCourse?
    
    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    nearbySection
                } else {
                    searchResultsSection
                }
            }
            .navigationTitle("Discover")
            .task {
                if let region = locationManager.getRegionAroundCurrentLocation() {
                    searchRegion = region
                    await searchVM.loadNearbyCourses(region: region)
                }
                locationManager.locationUpdated = { location in
                    Task {
                        let region = MKCoordinateRegion(
                            center: location.coordinate,
                            latitudinalMeters: 10000,
                            longitudinalMeters: 10000
                        )
                        searchRegion = region
                        await searchVM.loadNearbyCourses(region: region)
                    }
                }
            }
            .onDisappear {
                searchTask?.cancel()
            }
            .onChange(of: searchText) { oldValue, newValue in
                searchTask?.cancel()
                guard !newValue.isEmpty else {
                    searchVM.courses.removeAll()
                    return
                }
                searchTask = Task {
                    do {
                        try await Task.sleep(for: .milliseconds(300))
                        if Task.isCancelled { return }
                        if searchText == newValue {
                            try await searchVM.search(text: newValue, region: searchRegion)
                        }
                    } catch {
                        if !Task.isCancelled {
                            print("ERROR: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .sheet(item: $selectedCourse) { course in
                CourseDetailView(course: course)
            }
        }
        .searchable(text: $searchText, prompt: "Search golf courses...")
        .autocorrectionDisabled()
    }
    
    var nearbySection: some View {
        Group {
            if searchVM.isLoading {
                ProgressView("Finding nearby courses...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchVM.nearbyCourses.isEmpty {
                ContentUnavailableView(
                    "No Nearby Courses",
                    systemImage: "flag.slash",
                    description: Text("Enable location access to find courses near you.")
                )
            } else {
                List(searchVM.nearbyCourses) { course in
                    CourseRow(course: course)
                        .onTapGesture {
                            selectedCourse = course
                        }
                }
                .listStyle(.plain)
            }
        }
    }
    
    var searchResultsSection: some View {
        Group {
            if searchVM.courses.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List(searchVM.courses) { course in
                    CourseRow(course: course)
                        .onTapGesture {
                            selectedCourse = course
                        }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct CourseRow: View {
    let course: GolfCourse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(course.name)
                .font(.headline)
            Text(course.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct CourseDetailView: View {
    let course: GolfCourse
    @FirestoreQuery(
        collectionPath: "bucketlist",
        predicates: [.whereField("userId", isEqualTo: Auth.auth().currentUser?.uid ?? "")]
    ) var bucketList: [BucketList]
    @State private var showRatingSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var isInBucketList: Bool {
        BucketListViewModel.isInBucketList(courseId: course.id, bucketList: bucketList)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    Map {
                        Marker(course.name, coordinate: course.coordinate)
                            .tint(Color("flagDarkGreen"))
                    }
                    .frame(height: 220)
                    .mapControls {
                        MapScaleView()
                        MapUserLocationButton()
                        MapCompass()
                    }
                    .onTapGesture {
                        course.mapItem_.openInMaps()
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(course.address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Rate button
                        Button {
                            showRatingSheet = true
                        } label: {
                            Label("Rate This Course", systemImage: "star")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("flagDarkGreen"))
                        
                        // Bucket list button
                        Button {
                            Task {
                                if isInBucketList {
                                    if let entry = BucketListViewModel.entry(for: course.id, in: bucketList) {
                                        BucketListViewModel.removeCourse(bucketList: entry)
                                    }
                                } else {
                                    let entry = BucketList(
                                        courseId: course.id,
                                        courseName: course.name,
                                        courseAddress: course.address,
                                        latitude: course.latitude,
                                        longitude: course.longitude
                                    )
                                    await BucketListViewModel.addCourse(course: entry)
                                }
                            }
                        } label: {
                            Label(
                                isInBucketList ? "Remove from Bucket List" : "Add to Bucket List",
                                systemImage: isInBucketList ? "bookmark.fill" : "bookmark"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("flagDarkGreen"))
                    }
                    .padding()
                }
            }
            .navigationTitle(course.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showRatingSheet) {
                RatingSheetView(
                    courseName: course.name,
                    courseAddress: course.address,
                    courseId: course.id,
                    latitude: course.latitude,
                    longitude: course.longitude
                )
            }
        }
    }
}

#Preview {
    DiscoverView(locationManager: LocationManager())
}
