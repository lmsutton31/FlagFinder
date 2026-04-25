//
//  CoursePhotoViewModel.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SwiftUI

class CoursePhotoViewModel {
    
    static func saveImage(rating: CourseRating, photo: CoursePhoto, data: Data) async {
        guard let ratingId = rating.id else {
            print("ERROR: Should never be called without a valid rating.id")
            return
        }
        
        let storage = Storage.storage().reference()
        let metadata = StorageMetadata()
        
        if photo.id == nil {
            photo.id = UUID().uuidString
        }
        
        metadata.contentType = "image/jpeg"
        let path = "\(ratingId)/\(photo.id ?? "n/a")"
        
        do {
            let storageRef = storage.child(path)
            let returnedMetaData = try await storageRef.putDataAsync(data, metadata: metadata)
            print("✅ Photo saved to Storage: \(returnedMetaData)")
            
            guard let url = try? await storageRef.downloadURL() else {
                print("ERROR: Could not get downloadURL")
                return
            }
            photo.imageURLString = url.absoluteString
            print("photo.imageURLString: \(photo.imageURLString)")
            
            let db = Firestore.firestore()
            do {
                try db.collection("ratings")
                    .document(ratingId)
                    .collection("photos")
                    .document(photo.id ?? "n/a")
                    .setData(from: photo)
                print("✅ Photo document saved to Firestore")
            } catch {
                print("ERROR: Could not save photo to Firestore. \(error.localizedDescription)")
            }
        } catch {
            print("ERROR: Could not save photo to Storage. \(error.localizedDescription)")
        }
    }
}
