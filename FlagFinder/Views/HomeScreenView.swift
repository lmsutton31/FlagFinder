//
//  HomeScreenView.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import SwiftUI

struct HomeScreenView: View {
    @State private var locationManager = LocationManager()
    
    var body: some View {
        TabView {
            MyCoursesView()
                .tabItem {
                    Label("My Courses", systemImage: "flag.fill")
                }
            DiscoverView(locationManager: locationManager)
                .tabItem {
                    Label("Discover", systemImage: "location.magnifyingglass")
                }
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(Color("flagLightGreen"))
    }
}

#Preview {
    HomeScreenView()
}
