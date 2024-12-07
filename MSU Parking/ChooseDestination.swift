//
//  ChooseLot.swift
//  MSU Parking
//
//  Created by Zain Ul Abidin on 10/29/24.
//


import SwiftUI
import SwiftData

struct ChooseDestinationView: View {
    @Query var regions: [RegionEntity]
    @Query var entrances: [EntranceEntity]
    @State private var selectedRegion: RegionEntity?

    var filteredDestinations: [EntranceEntity] {
        if let region = selectedRegion {
            return entrances.filter { $0.region.id == region.id }
        }
        return []
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView()
                
                // Region picker
                RegionPicker(selectedRegion: $selectedRegion, regions: regions)
                
                // Scrollable destination list
                ScrollView {
                    if filteredDestinations.isEmpty {
                        EmptyStateView(message: "No Building Found!")
                    } else {
                        DestinationGridView(destinations: filteredDestinations)
                    }
                }
                .padding(.top)
            }
        }
    }
}

// MARK: - Subviews

/// A reusable header for the destination view
struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Destination")
                .font(.headline)
                .foregroundColor(.primary)
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.blue)
        }
        .padding()
    }
}

/// A picker for selecting the region
struct RegionPicker: View {
    @Binding var selectedRegion: RegionEntity?
    let regions: [RegionEntity]
    
    var body: some View {
        Picker("Select Region", selection: $selectedRegion) {
            ForEach(regions) { region in
                Text(region.name ?? "Unknown").tag(region as RegionEntity?)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

/// A grid view displaying the filtered destinations
struct DestinationGridView: View {
    let destinations: [EntranceEntity]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(destinations) { destination in
                NavigationLink(
                    destination: ChooseLotView(destination: destination)
                ) {
                    DestinationCard(destination: destination)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

/// A card representing a single destination
struct DestinationCard: View {
    let destination: EntranceEntity
    
    var body: some View {
        VStack {
            Image(systemName: "building.2.fill")
                .foregroundColor(.blue)
            Text(destination.name ?? "Unknown")
                .font(.headline)
                .foregroundColor(.primary)
                .fontWeight(.bold)
        }
        .frame(width: 100, height: 100)
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

/// A reusable empty state view
struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .foregroundColor(.gray)
            .padding()
    }
}

// MARK: - ChooseLotView Stub

/// Stubbed ChooseLotView for demonstration purposes
struct ChooseLotView: View {
    let destination: EntranceEntity
    
    var body: some View {
        Text("Choose a lot near \(destination.name ?? "Unknown")")
    }
}

// MARK: - Preview

#Preview {
    ChooseDestinationView()
}
