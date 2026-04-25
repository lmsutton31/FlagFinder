//
//  CoursePhoto.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class CoursePhoto: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = ""
    var caption = ""
    var postedBy: String = Auth.auth().currentUser?.email ?? ""
    var postedOn = Date()
    
    init(
        id: String? = nil,
        imageURLString: String = "",
        caption: String = "",
        postedBy: String = Auth.auth().currentUser?.email ?? "",
        postedOn: Date = Date()
    ) {
        self.id = id
        self.imageURLString = imageURLString
        self.caption = caption
        self.postedBy = postedBy
        self.postedOn = postedOn
    }
}

extension CoursePhoto {
    static var preview: CoursePhoto {
        let newPhoto = CoursePhoto(
            id: "1",
            imageURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Pebble_Beach_Golf_Links_%28cropped%29.jpg/1280px-Pebble_Beach_Golf_Links_%28cropped%29.jpg",
            caption: "18th hole view",
            postedBy: "preview@test.com",
            postedOn: Date()
        )
        return newPhoto
    }
}
