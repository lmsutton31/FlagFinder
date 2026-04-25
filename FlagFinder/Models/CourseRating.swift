//
//  CourseRating.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct CourseRating: Identifiable, Codable {
    @DocumentID var id: String?
    var courseId: String = ""
    var courseName: String = ""
    var courseAddress: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var score: Double = 7.0          // 1.0 – 10.0 in 0.1 increments
    var tags: [String] = []
    var note: String = ""
    var userId: String = Auth.auth().currentUser?.uid ?? ""
    var userEmail: String = Auth.auth().currentUser?.email ?? ""
    var dateRated: Date = Date()
    var strokes: Int? = nil
    var datePlayed: Date? = nil
    
    // Computed tier label based on score (not stored in Firestore)
    var tierLabel: String {
        switch score {
        case 9.5...10.0: return "S"
        case 8.5..<9.5:  return "A"
        case 7.0..<8.5:  return "B"
        case 5.5..<7.0:  return "C"
        case 4.0..<5.5:  return "D"
        default:          return "F"
        }
    }
}

// Preview helper - matches Spot.preview pattern
extension CourseRating {
    static var preview: CourseRating {
        CourseRating(
            id: "1",
            courseId: "pebble-beach",
            courseName: "Pebble Beach Golf Links",
            courseAddress: "Pebble Beach, CA",
            latitude: 36.5681,
            longitude: -121.9484,
            score: 9.2,
            tags: ["Scenic views", "Bucket list"],
            note: "Best finishing hole in golf.",
            userId: "previewUser",
            userEmail: "preview@test.com",
            dateRated: Date()
        )
    }
}

// Available tags users can apply to a rating
struct CourseTags {
    static let all: [String] = [
        "Scenic views",
        "Great greens",
        "Tough layout",
        "Worth the cost",
        "Bucket list",
        "Good pace",
        "Great staff",
        "Well maintained",
        "Fun for all levels",
        "Links style"
    ]
}
