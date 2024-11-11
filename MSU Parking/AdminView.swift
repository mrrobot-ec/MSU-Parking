//
//  AdminView.swift
//  MSU Parking
//
//  Created by gopityro on 2024-11-09.
//

import SwiftUI

struct AdminView: View {
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.crop.circle.badge.plus")
                    .foregroundColor(.blue)
                Text("Admin")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding()
            
            TabView {
                AddDataView()
                    .tabItem {
                        Label("Add Data", systemImage: "plus.circle")
                    }
                
                ViewDataView()
                    .tabItem {
                        Label("View Data", systemImage: "list.bullet")
                    }
            }
        }
        .navigationTitle("Admin Panel")
    }
}

struct AddDataView: View {
    @EnvironmentObject var dataManager: DataManager

    @State private var name: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var floors: String = ""
    @State private var maxCapacity: String = ""
    @State private var selectedType: ParkingAreaType = .lot // Enum to track selected type
    
    // State to handle the alert
    @State private var showAlert = false
    @State private var alertMessage = ""

    enum ParkingAreaType: String, CaseIterable, Identifiable {
        case lot = "Lot"
        case building = "Building"
        
        var id: String { self.rawValue }
    }

    var body: some View {
        Form {
            // General Information Section
            Section(header: HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text("General Information")
                    .font(.headline)
            }) {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 5)
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.green)
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.vertical, 5)

                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.green)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.vertical, 5)
            }

            // Specifications Section
            Section(header: HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(.purple)
                Text("Specifications")
                    .font(.headline)
            }) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.orange)
                    TextField("Floors", text: $floors)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.vertical, 5)
                
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.green)
                    TextField("Max Capacity", text: $maxCapacity)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.vertical, 5)
                
                Picker("Parking Area Type", selection: $selectedType) {
                    ForEach(ParkingAreaType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Makes it a segmented control
                .padding(.vertical, 5)
            }

            // Save Button
            Button(action: addParkingArea) {
                Text("Save")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid() ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!isFormValid())
            .padding(.vertical)
        }
        .navigationTitle("Add Data")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Success"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    private func isFormValid() -> Bool {
        return !name.isEmpty &&
            Double(latitude) != nil &&
            Double(longitude) != nil &&
            Int(floors) != nil &&
            Int(maxCapacity) != nil
    }
    
    private func addParkingArea() {
        guard let latitude = Double(latitude),
              let longitude = Double(longitude),
              let floors = Int(floors),
              let maxCapacity = Int(maxCapacity) else {
            return
        }

        // Add based on the selected type (Lot or Building)
        let nearestEntranceId = dataManager.entrances.first?.id ?? ""
        if selectedType == .lot {
            dataManager.addLot(name: name, coordinates: [latitude, longitude], floors: floors, maxCapacity: maxCapacity, nearestEntranceId: nearestEntranceId)
            alertMessage = "Parking Lot '\(name)' has been added successfully."
        } else {
            dataManager.addBuilding(name: name, coordinates: [latitude, longitude], floors: floors, maxCapacity: maxCapacity, nearestEntranceId: nearestEntranceId)
            alertMessage = "Building '\(name)' has been added successfully."
        }

        // Show the success alert
        showAlert = true

        clearForm()
    }

    private func clearForm() {
        name = ""
        latitude = ""
        longitude = ""
        floors = ""
        maxCapacity = ""
        selectedType = .lot // Reset to "Lot" by default
    }
}

struct ViewDataView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedLot: Lot?
    @State private var selectedBuilding: Building?
    @State private var isEditing = false

    var body: some View {
        List {
            // "Lots" Section with Icon and Larger Header
            Section(header:
                HStack {
                    Image(systemName: "car.2.fill")
                        .foregroundColor(.blue)
                    Text("Lots")
                        .font(.title2)
                        .bold()
                }
                .padding(.vertical, 4)
            ) {
                ForEach(dataManager.lots) { lot in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(lot.name)
                                .font(.headline)
                            Spacer()
                            Button("Edit") {
                                selectedLot = lot
                                isEditing = true
                            }
                        }

                        // Differentiated ID styling
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.purple)
                            Text("ID: \(lot.id)")
                                .foregroundColor(.purple)
                                .italic()
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                        
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.blue)
                            Text("Location: \(lot.coordinates[0]), \(lot.coordinates[1])")
                        }
                        
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.gray)
                            Text("Floors: \(lot.floors)")
                        }
                        
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.green)
                            Text("Capacity: \(lot.maxCapacity)")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // "Buildings" Section with Icon and Larger Header
            Section(header:
                HStack {
                    Image(systemName: "building.2.crop.circle.fill")
                        .foregroundColor(.orange)
                    Text("Buildings")
                        .font(.title2)
                        .bold()
                }
                .padding(.vertical, 4)
            ) {
                ForEach(dataManager.buildings) { building in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(building.name)
                                .font(.headline)
                            Spacer()
                            Button("Edit") {
                                selectedBuilding = building
                                isEditing = true
                            }
                        }

                        // Differentiated ID styling
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.purple)
                            Text("ID: \(building.id)")
                                .foregroundColor(.purple)
                                .italic()
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                        
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.blue)
                            Text("Location: \(building.coordinates[0]), \(building.coordinates[1])")
                        }
                        
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.gray)
                            Text("Floors: \(building.floors)")
                        }
                        
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.green)
                            Text("Capacity: \(building.maxCapacity)")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("View Data")
        .sheet(isPresented: $isEditing, onDismiss: {
            selectedLot = nil
            selectedBuilding = nil
        }) {
            if let lot = selectedLot {
                EditDataView(isPresenting: $isEditing, lot: lot)
                    .environmentObject(dataManager)
            } else if let building = selectedBuilding {
                EditDataView(isPresenting: $isEditing, building: building)
                    .environmentObject(dataManager)
            }
        }
    }
}


struct EditDataView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var isPresenting: Bool
    
    @State private var name: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var floors: String = ""
    @State private var maxCapacity: String = ""
    
    @State private var showDeleteAlert = false
    
    var lot: Lot?
    var building: Building?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    // Edit Information Section
                    Section(header: Text("Edit Information")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.top, 10)
                    ) {
                        Group {
                            CustomTextField(title: "Name", text: $name, systemImage: "textformat")
                            CustomTextField(title: "Latitude", text: $latitude, systemImage: "location.fill", keyboardType: .decimalPad)
                            CustomTextField(title: "Longitude", text: $longitude, systemImage: "location.fill", keyboardType: .decimalPad)
                            CustomTextField(title: "Floors", text: $floors, systemImage: "building.2.fill", keyboardType: .numberPad)
                            CustomTextField(title: "Max Capacity", text: $maxCapacity, systemImage: "person.3.fill", keyboardType: .numberPad)
                        }
                    }

                    // Save Button
                    Section {
                        Button(action: saveChanges) {
                            Text("Save Changes")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                                .padding(.top, 0)
                                .padding(.bottom, 0)
                        }
                        .padding(.horizontal)
                        .disabled(!isFormValid())
                    }
                    
                    // Delete Button
                    Section {
                        Button(action: { showDeleteAlert = true }) {
                            Text("Delete \(lot != nil ? "Lot" : "Building")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.top, 0)
                        }
                        .padding(.horizontal)
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete \(lot != nil ? "Lot" : "Building")"),
                                message: Text("Are you sure you want to delete this \(lot != nil ? "lot" : "building")? This action cannot be undone."),
                                primaryButton: .destructive(Text("Delete")) {
                                    deleteItem()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .navigationBarTitle("Edit Data", displayMode: .inline)
                .navigationBarItems(trailing: Button("Cancel") {
                    isPresenting = false
                })
                .onAppear(perform: loadData)
            }
        }
    }

    // Custom TextField with Icon
    private func CustomTextField(title: String, text: Binding<String>, systemImage: String, keyboardType: UIKeyboardType = .default) -> some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.blue)
                .padding(.leading, 10)
            TextField(title, text: text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.gray, lineWidth: 1))
                .padding(.vertical, 5)
        }
    }

    // Form validation
    private func isFormValid() -> Bool {
        return !name.isEmpty &&
            Double(latitude) != nil &&
            Double(longitude) != nil &&
            Int(floors) != nil &&
            Int(maxCapacity) != nil
    }

    // Load data into the form
    private func loadData() {
        if let lot = lot {
            name = lot.name
            latitude = "\(lot.coordinates[0])"
            longitude = "\(lot.coordinates[1])"
            floors = "\(lot.floors)"
            maxCapacity = "\(lot.maxCapacity)"
        } else if let building = building {
            name = building.name
            latitude = "\(building.coordinates[0])"
            longitude = "\(building.coordinates[1])"
            floors = "\(building.floors)"
            maxCapacity = "\(building.maxCapacity)"
        }
    }

    // Save the changes
    private func saveChanges() {
        guard let latitude = Double(latitude),
              let longitude = Double(longitude),
              let floors = Int(floors),
              let maxCapacity = Int(maxCapacity) else { return }
        
        if let lot = lot {
            dataManager.updateLot(lot, name: name, coordinates: [latitude, longitude], floors: floors, maxCapacity: maxCapacity)
        } else if let building = building {
            dataManager.updateBuilding(building, name: name, coordinates: [latitude, longitude], floors: floors, maxCapacity: maxCapacity)
        }
        
        isPresenting = false
    }

    // Delete the lot or building
    private func deleteItem() {
        if let lot = lot {
            dataManager.deleteLot(lot)
        } else if let building = building {
            dataManager.deleteBuilding(building)
        }
        
        isPresenting = false
    }
}

#Preview {
    AdminView()
        .environmentObject(DataManager.shared)  // Inject DataManager
}