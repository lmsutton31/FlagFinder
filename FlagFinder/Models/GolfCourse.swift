//
//  GolfCourse.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import Foundation
import MapKit
 
struct GolfCourse: Identifiable {
    let id: String
    private var mapItem: MKMapItem
 
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        self.id = mapItem.identifier?.rawValue ?? UUID().uuidString
    }
 
    var name: String {
        mapItem.name ?? "Unknown Course"
    }
    var address: String {
        mapItem.address?.shortAddress ?? ""
    }
    var latitude: CLLocationDegrees {
        mapItem.location.coordinate.latitude
    }
    var longitude: CLLocationDegrees {
        mapItem.location.coordinate.longitude
    }
    var coordinate: CLLocationCoordinate2D {
        mapItem.location.coordinate
    }
    var mapItem_: MKMapItem {
        mapItem
    }
}
 
extension GolfCourse: Hashable {
    static func == (lhs: GolfCourse, rhs: GolfCourse) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
