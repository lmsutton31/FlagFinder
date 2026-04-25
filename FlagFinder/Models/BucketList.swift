//
//  BucketList.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct BucketList: Identifiable, Codable {
    @DocumentID var id: String?
    var courseId: String = ""
    var courseName: String = ""
    var courseAddress: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var userId: String = Auth.auth().currentUser?.uid ?? ""
    var dateAdded: Date = Date()
}

extension BucketList {
    static var preview: BucketList {
        BucketList(
            id: "1",
            courseId: "pebble-beach",
            courseName: "Pebble Beach Golf Links",
            courseAddress: "Pebble Beach, CA",
            latitude: 36.5681,
            longitude: -121.9484,
            userId: "previewUser",
            dateAdded: Date()
        )
    }
}
