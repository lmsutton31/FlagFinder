//
//  GolfCourseSearchViewModel.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import Foundation
import MapKit
 
@MainActor
@Observable
class GolfCourseSearchViewModel {
    var courses: [GolfCourse] = []
    var nearbyCourses: [GolfCourse] = []
    var isLoading = false
 
    func search(text: String, region: MKCoordinateRegion) async throws {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text + " golf course"
        searchRequest.region = region
        searchRequest.resultTypes = .pointOfInterest
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
        if response.mapItems.isEmpty {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No golf courses found"])
        }
        self.courses = response.mapItems.map(GolfCourse.init)
    }
 
    func loadNearbyCourses(region: MKCoordinateRegion) async {
        isLoading = true
        do {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = "golf course"
            searchRequest.region = region
            searchRequest.resultTypes = .pointOfInterest
            let search = MKLocalSearch(request: searchRequest)
            let response = try await search.start()
            self.nearbyCourses = response.mapItems.map(GolfCourse.init)
        } catch {
            print("ERROR loading nearby courses: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
