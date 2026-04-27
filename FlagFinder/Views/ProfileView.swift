//
//  ProfileView.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @FirestoreQuery(
        collectionPath: "ratings",
        predicates: [.whereField("userId", isEqualTo: Auth.auth().currentUser?.uid ?? "")]
    ) var ratings: [CourseRating]
    
    @FirestoreQuery(
        collectionPath: "bucketlist",
        predicates: [.whereField("userId", isEqualTo: Auth.auth().currentUser?.uid ?? "")]
    ) var bucketList: [BucketList]
    
    @State private var showingAlert = false
    @State private var isSignedOut = false
    
    var averageScore: Double {
        guard !ratings.isEmpty else { return 0.0 }
        return ratings.map { $0.score }.reduce(0, +) / Double(ratings.count)
    }
    
    var sTierCount: Int {
        ratings.filter { $0.tierLabel == "S" }.count
    }
    
    var bestCourse: CourseRating? {
        ratings.max(by: { $0.score < $1.score })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(Color("flagDarkGreen"))
                        
                        Text(Auth.auth().currentUser?.email ?? "")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                    
                    
                    HStack(spacing: 12) {
                        StatCard(title: "Played", value: "\(ratings.count)")
                        StatCard(title: "Avg Rating", value: ratings.isEmpty ? "—" : String(format: "%.1f", averageScore))
                        StatCard(title: "# of S Tier Courses", value: "\(sTierCount)")
                    }
                    .padding(.horizontal)
                    
                    if let best = bestCourse {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Best Course")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color("flagLightGreen"))
                                        .frame(width: 44, height: 44)
                                    Text(best.tierLabel)
                                        .font(.headline)
                                        .foregroundStyle(Color("flagDarkGreen"))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(best.courseName)
                                        .font(.headline)
                                    Text(best.courseAddress)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(String(format: "%.1f", best.score))
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color("flagDarkGreen"))
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Bucket List")
                                .font(.headline)
                            Spacer()
                            Text("\(bucketList.count) courses")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        
                        if bucketList.isEmpty {
                            Text("No courses saved yet. Head to Discover and tap a course to add it.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(bucketList) { entry in
                                    HStack(spacing: 12) {
                                        Image(systemName: "bookmark.fill")
                                            .foregroundStyle(Color("flagDarkGreen"))
                                            .frame(width: 24)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(entry.courseName)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(entry.courseAddress)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Button {
                                            BucketListViewModel.removeCourse(bucketList: entry)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    Button("Sign Out") {
                        showingAlert = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Profile")
            .alert("Sign out?", isPresented: $showingAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    do {
                        try Auth.auth().signOut()
                        isSignedOut = true
                    } catch {
                        print("ERROR: Could not sign out. \(error.localizedDescription)")
                    }
                }
            }
            .fullScreenCover(isPresented: $isSignedOut) {
                LoginView()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color("flagDarkGreen"))
                .minimumScaleFactor(0.5)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProfileView()
}
