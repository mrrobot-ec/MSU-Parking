//
//  ChooseSpot.swift
//  MSU Parking
//
//  Created by Zain Ul Abidin on 10/31/24.
//

import SwiftUI

struct ChooseSpot: View {
    var spotSelection: ParkingBuildingSelection
    @State private var isButtonPressed = false
    @State private var successMessage: String?
    
    @Environment(\.presentationMode) var presentationMode // env variable defined to keep view's presentation state and dismiss when needed
    
    var body: some View {
        VStack {
            switch spotSelection {
                
                // user chose a lot to park
            case .lot(let lot):
                
                let chosenSpot = findFirstAvailableSpot(parkingSpots: lot.parkingSpots)
                
                Divider()
                
                if let spot = chosenSpot {
                    Text("Parking at \(lot.name)").font(.title3)
                        .padding()
                        .fontWeight(.bold)
                    
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: lot.parkingSpots[0][0].count), // Number of columns based on parking structure
                        spacing: 10
                    ) {
                        // Iterate through rows
                        ForEach(0..<lot.parkingSpots[spot.floor].count, id: \.self) { rowIndex in
                            // Iterate over columns in the row
                            ForEach(0..<lot.parkingSpots[spot.floor][rowIndex].count, id: \.self) { columnIndex in
                                let isOccupied = lot.parkingSpots[spot.floor][rowIndex][columnIndex]
                                
                                if !isOccupied {
                                    Image(systemName: "car.fill")
                                        .foregroundColor(.blue)
                                        .padding(4)
                                } else {
                                    Image(systemName: "car")
                                        .foregroundColor(.red)
                                        .padding(4)
                                }
                            }
                        }
                    }
                    
                    Text("Park at Spot: \(spot.row)\(spot.column)")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Button("Accept") {
                        isButtonPressed = true
                        lot.parkingSpots[spot.floor][spot.row][spot.column] = true
                        lot.availableSpots -= 1
                        successMessage = "Successfully parked at Spot: \(spot.row)\(spot.column)"
                    }
                    .alert(isPresented: $isButtonPressed) {
                        Alert(
                            title: Text("Success"),
                            message: Text(successMessage ?? ""),
                            dismissButton: .default(Text("OK")) {
                                isButtonPressed = true
                                self.presentationMode.wrappedValue.dismiss()  // <-- Dismiss the view
                                
                            }
                        )
                    }
                    .disabled(isButtonPressed)
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("No available spots")
                        .foregroundColor(.gray)
                }
                
                // user chose a building to park
            case .building(let building):
                
                let chosenSpot = findFirstAvailableSpot(parkingSpots: building.parkingSpots)
                
                if let spot = chosenSpot {
                    
                    Text("Parking in \(building.name), Floor \(spot.floor + 1)").font(.title3)
                        .padding()
                        .fontWeight(.bold)
                    
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: building.parkingSpots[0][0].count), // Number of columns based on parking structure
                        spacing: 10
                    ) {
                        // Iterate through rows
                        ForEach(0..<building.parkingSpots[spot.floor].count, id: \.self) { rowIndex in
                            // Iterate over columns in the row
                            ForEach(0..<building.parkingSpots[spot.floor][rowIndex].count, id: \.self) { columnIndex in
                                let isOccupied = building.parkingSpots[spot.floor][rowIndex][columnIndex]
                                
                                if !isOccupied {
                                    Image(systemName: "car.fill")
                                        .foregroundColor(.blue)
                                        .padding(4)
                                } else {
                                    Image(systemName: "car")
                                        .foregroundColor(.red)
                                        .padding(4)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    Text("Park at Spot: \(spot.row)\(spot.column)")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Button("Accept") {
                        isButtonPressed = true
                        building.parkingSpots[spot.floor][spot.row][spot.column] = true
                        building.availableSpots -= 1
                        successMessage = "Successfully parked at Floor \(spot.floor + 1), Spot: \(spot.row)\(spot.column)"
                    }
                    .alert(isPresented: $isButtonPressed) {
                        Alert(
                            title: Text("Success"),
                            message: Text(successMessage ?? ""),
                            dismissButton: .default(Text("OK")) {
                                isButtonPressed = true
                                self.presentationMode.wrappedValue.dismiss()  // Dismiss the view
                                
                            }
                        )
                    }
                    .disabled(isButtonPressed)
                    .buttonStyle(.borderedProminent)
                } else {
                    Text("No available spots")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}

// Helper function for finding available spots
func findFirstAvailableSpot(parkingSpots: [[[Bool]]]) -> (floor: Int, row: Int, column: Int)? {
    for (floor, rows) in parkingSpots.enumerated() {
        for (row, columns) in rows.enumerated() {
            for (column, isOccupied) in columns.enumerated() {
                if !isOccupied {
                    return (floor, row, column)
                }
            }
        }
    }
    return nil
}

//#Preview {
//    ChooseSpot(spotSelection: ParkingBuildingSelection.building(buildings[2]))
//}

