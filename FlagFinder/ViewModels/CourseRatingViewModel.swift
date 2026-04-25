//
//  CourseRatingViewModel.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct CourseRatingViewModel {
    
    static func saveRating(rating: CourseRating) async {
        let db = Firestore.firestore()
        
        if let id = rating.id {
            do {
                try db.collection("ratings").document(id).setData(from: rating)
                print("✅ Updated rating for \(rating.courseName)")
            } catch {
                print("ERROR: Could not update rating. \(error.localizedDescription)")
            }
        } else {
            do {
                try db.collection("ratings").addDocument(from: rating)
                print("✅ Saved new rating for \(rating.courseName)")
            } catch {
                print("ERROR: Could not save rating. \(error.localizedDescription)")
            }
        }
    }
    
    static func deleteRating(rating: CourseRating) {
        guard let id = rating.id else {
            print("ERROR: No id on rating to delete")
            return
        }
        let db = Firestore.firestore()
        db.collection("ratings").document(id).delete { error in
            if let error = error {
                print("ERROR: Could not delete rating. \(error.localizedDescription)")
            } else {
                print("✅ Deleted rating for \(rating.courseName)")
            }
        }
    }
}
