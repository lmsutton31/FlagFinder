//
//  RatingSheetView.swift
//  FlagFinder
//
//  Created by Luke Sutton on 4/22/26.
//

import SwiftUI

struct RatingSheetView: View {
    let courseName: String
    let courseAddress: String
    let courseId: String
    let latitude: Double
    let longitude: Double
    var existingRating: CourseRating? = nil
    
    @State private var score: Double = 7.0
    @State private var selectedTags: Set<String> = []
    @State private var note: String = ""
    @State private var hasStrokes: Bool = false
    @State private var strokes: Int = 90
    @State private var hasDate: Bool = false
    @State private var datePlayed: Date = Date()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                  
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Score")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.1f / 10  ·  %@ Tier", score, tierLabel))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("flagDarkGreen"))
                        }
                        Slider(value: $score, in: 1...10, step: 0.1)
                            .tint(Color("flagDarkGreen"))
                        HStack {
                            Text("1  ←  Worst")
                            Spacer()
                            Text("Best  →  10")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                    
                  
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Round Details")
                            .font(.headline)
                        
                        // Strokes toggle
                        Toggle("Add Stroke Count", isOn: $hasStrokes)
                            .tint(Color("flagDarkGreen"))
                        
                        if hasStrokes {
                            HStack {
                                Text("Strokes")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Stepper("\(strokes)", value: $strokes, in: 50...200)
                                    .fixedSize()
                            }
                        }
                        
                        // Date toggle
                        Toggle("Add Date Played", isOn: $hasDate)
                            .tint(Color("flagDarkGreen"))
                        
                        if hasDate {
                            DatePicker(
                                "Date Played",
                                selection: $datePlayed,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .foregroundStyle(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tags")
                            .font(.headline)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
                            ForEach(CourseTags.all, id: \.self) { tag in
                                let isSelected = selectedTags.contains(tag)
                                Text(tag)
                                    .font(.caption)
                                    .fontWeight(isSelected ? .semibold : .regular)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .frame(maxWidth: .infinity)
                                    .background(isSelected ? Color("flagLightGreen") : Color(.systemGray6))
                                    .foregroundStyle(isSelected ? Color("flagDarkGreen") : Color.secondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isSelected ? Color("flagLightGreen") : Color.clear, lineWidth: 1)
                                    }
                                    .onTapGesture {
                                        if isSelected {
                                            selectedTags.remove(tag)
                                        } else {
                                            selectedTags.insert(tag)
                                        }
                                    }
                            }
                        }
                    }
                    
                    Divider()
                    
                
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(.headline)
                        TextField("What made this round memorable?", text: $note, axis: .vertical)
                            .lineLimit(3...5)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .navigationTitle(existingRating == nil ? "Rate Course" : "Edit Rating")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveRating()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let existing = existingRating {
                    score = existing.score
                    selectedTags = Set(existing.tags)
                    note = existing.note
                    if let existingStrokes = existing.strokes {
                        hasStrokes = true
                        strokes = existingStrokes
                    }
                    if let existingDate = existing.datePlayed {
                        hasDate = true
                        datePlayed = existingDate
                    }
                }
            }
        }
    }
    
    var tierLabel: String {
        switch score {
        case 9.5...10.0: return "S"
        case 8.5..<9.5:  return "A"
        case 7.0..<8.5:  return "B"
        case 5.5..<7.0:  return "C"
        case 4.0..<5.5:  return "D"
        default:          return "F"
        }
    }
    
    func saveRating() async {
        var rating = existingRating ?? CourseRating()
        rating.courseId = courseId
        rating.courseName = courseName
        rating.courseAddress = courseAddress
        rating.latitude = latitude
        rating.longitude = longitude
        rating.score = score
        rating.tags = Array(selectedTags)
        rating.note = note
        rating.strokes = hasStrokes ? strokes : nil
        rating.datePlayed = hasDate ? datePlayed : nil
        rating.dateRated = Date()
        
        await CourseRatingViewModel.saveRating(rating: rating)
        dismiss()
    }
}

#Preview {
    RatingSheetView(
        courseName: "Pebble Beach Golf Links",
        courseAddress: "Pebble Beach, CA",
        courseId: "pebble",
        latitude: 36.5681,
        longitude: -121.9484
    )
}
