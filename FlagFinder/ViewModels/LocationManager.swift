//
//  LocationManager.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import Foundation
import MapKit
import SwiftUI
 
@Observable
 
class LocationManager: NSObject, CLLocationManagerDelegate {
    // *** Always add info.plist message for Privacy
    
    var location: CLLocation?
    private let locationManager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var errorMessage: String?
    var locationUpdated: ((CLLocation) -> Void)? //this is a function that can be called
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //get a region around current location
    func getRegionAroundCurrentLocation(radiusInMeters: CLLocationDistance = 10000) -> MKCoordinateRegion? {
        guard let location = location else {
            return nil
        }
        return MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
    }
}
 
//Delegate methods that apple has created and will call, but that we filled out
extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        } //use last location as the location
        location = newLocation
        //call the callback function to indicate weve updated a location
        locationUpdated?(newLocation)
        
        //you can uncomment this when you only want to get the location once, not repeatedly
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("LocationManager authorization granted.")
        case .denied, .restricted:
            print("LocationManager authorization denied.")
            errorMessage = "LocationManager access denied."
            manager.stopUpdatingLocation()
        case .notDetermined:
            print("LocationManager authorization not determined.")
            manager.requestWhenInUseAuthorization()
        @unknown default:
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        errorMessage = error.localizedDescription
        print("ERROR: LocationManager: \(errorMessage ?? "n/a")")
    }
}
