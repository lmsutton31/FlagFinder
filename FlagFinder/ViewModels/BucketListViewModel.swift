//
//  BucketListViewModel.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct BucketListViewModel {
    
    static func addCourse(course: BucketList) async {
        let db = Firestore.firestore()
        do {
            try db.collection("bucketlist").addDocument(from: course)
            print("✅ Added \(course.courseName) to bucket list")
        } catch {
            print("ERROR: Could not add to bucket list. \(error.localizedDescription)")
        }
    }
    
    static func removeCourse(bucketList: BucketList) {
        guard let id = bucketList.id else {
            print("ERROR: No id on bucket list entry to delete")
            return
        }
        let db = Firestore.firestore()
        db.collection("bucketlist").document(id).delete { error in
            if let error = error {
                print("ERROR: Could not remove from bucket list. \(error.localizedDescription)")
            } else {
                print("✅ Removed \(bucketList.courseName) from bucket list")
            }
        }
    }
    
    // Check if a course is already in the user's bucket list
    static func isInBucketList(courseId: String, bucketList: [BucketList]) -> Bool {
        bucketList.contains(where: { $0.courseId == courseId })
    }
    
    // Get the bucket list entry for a course (needed to delete it)
    static func entry(for courseId: String, in bucketList: [BucketList]) -> BucketList? {
        bucketList.first(where: { $0.courseId == courseId })
    }
}
