//
//  MyCoursesView.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
 
struct MyCoursesView: View {
    @FirestoreQuery(
        collectionPath: "ratings",
        predicates: [.whereField("userId", isEqualTo: Auth.auth().currentUser?.uid ?? "")]
    ) var ratings: [CourseRating]
    
    var sTier: [CourseRating] {
        ratings.filter { $0.tierLabel == "S" }.sorted { $0.score > $1.score }
    }
    var aTier: [CourseRating] {
        ratings.filter { $0.tierLabel == "A" }.sorted { $0.score > $1.score }
    }
    var bTier: [CourseRating] {
        ratings.filter { $0.tierLabel == "B" }.sorted { $0.score > $1.score }
    }
    var cTier: [CourseRating] {
        ratings.filter { $0.tierLabel == "C" }.sorted { $0.score > $1.score }
    }
    var dTier: [CourseRating] {
        ratings.filter { $0.tierLabel == "D" }.sorted { $0.score > $1.score }
    }
    var fTier: [CourseRating] {
        ratings.filter { $0.tierLabel == "F" }.sorted { $0.score > $1.score }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if ratings.isEmpty {
                    ContentUnavailableView(
                        "No Courses Yet",
                        systemImage: "flag.slash",
                        description: Text("Head to Discover to find and rate your first course.")
                    )
                } else {
                    List {
                        tierSection("S Tier · 9.5 – 10.0", ratings: sTier)
                        tierSection("A Tier · 8.5 – 9.5", ratings: aTier)
                        tierSection("B Tier · 7.0 – 8.5", ratings: bTier)
                        tierSection("C Tier · 5.5 – 7.0", ratings: cTier)
                        tierSection("D Tier · 4.0 – 5.5", ratings: dTier)
                        tierSection("F Tier · Below 4.0", ratings: fTier)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Courses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("\(ratings.count) played")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    func tierSection(_ title: String, ratings: [CourseRating]) -> some View {
        if !ratings.isEmpty {
            Section(title) {
                ForEach(ratings) { rating in
                    NavigationLink {
                        RatingDetailView(rating: rating)
                    } label: {
                        CourseRatingRow(rating: rating)
                    }
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            CourseRatingViewModel.deleteRating(rating: rating)
                        }
                    }
                }
            }
        }
    }
}
 
struct CourseRatingRow: View {
    let rating: CourseRating
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(tierBgColor)
                    .frame(width: 38, height: 38)
                Text(rating.tierLabel)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(tierTextColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(rating.courseName)
                    .font(.headline)
                Text(rating.courseAddress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(String(format: "%.1f", rating.score))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color("flagDarkGreen"))
        }
        .padding(.vertical, 2)
    }
    
    var tierBgColor: Color {
        switch rating.tierLabel {
        case "S": return Color(red: 0.98, green: 0.93, blue: 0.85)
        case "A": return Color("flagLightGreen")
        case "B": return Color(red: 0.90, green: 0.95, blue: 0.98)
        case "C": return Color(red: 0.95, green: 0.94, blue: 0.91)
        case "D": return Color(red: 0.98, green: 0.90, blue: 0.90)
        default:  return Color(red: 0.95, green: 0.85, blue: 0.85)
        }
    }
    
    var tierTextColor: Color {
        switch rating.tierLabel {
        case "S": return Color(red: 0.39, green: 0.22, blue: 0.01)
        case "A": return Color("flagDarkGreen")
        case "B": return Color(red: 0.05, green: 0.27, blue: 0.48)
        case "C": return Color(red: 0.27, green: 0.27, blue: 0.25)
        case "D": return Color(red: 0.60, green: 0.10, blue: 0.10)
        default:  return Color(red: 0.50, green: 0.05, blue: 0.05)
        }
    }
}
 
#Preview {
    MyCoursesView()
}
