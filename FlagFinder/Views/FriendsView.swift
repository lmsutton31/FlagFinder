//
//  FriendsView.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import SwiftUI
import FirebaseAuth
 
struct FriendsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Friends Coming Soon",
                systemImage: "person.2",
                description: Text("See what your friends are playing and rating.")
            )
            .navigationTitle("Friends")
        }
    }
}

#Preview {
    FriendsView()
}
