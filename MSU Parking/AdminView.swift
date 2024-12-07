//
//  AdminView.swift
//  MSU Parking
//
//  Created by gopityro on 2024-11-09.
//

import SwiftUI
import SwiftData

struct AdminView: View {
    @EnvironmentObject var dataManager: DataManager  // Access the DataManager instance
    private let primaryColor = Color(red: 209/255, green: 25/255, blue: 13/255)  // #D1190D
    @State private var navigateToLogin: Bool = false
    @Environment(\.modelContext) private var context
    var body: some View {
        VStack {
            HStack {
                // Logo Button on the left (Logout button)
                Button(action: {
                    // Handle logout action
                    dataManager.logout()
                    navigateToLogin = true
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right") // Logout icon
                        .font(.title)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Align to left
                .background(
                    NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                        EmptyView()
                    }
                        .hidden()
                )
                Spacer()
                
                // Dynamically update text based on the currentUser
                if let user = dataManager.currentUser {
                    Text(user.role == "admin" ? "Admin: \(user.username)" : "User: \(user.firstName)")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .trailing) // Align to right
                } else {
                    Text("Not logged in")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing) // Align to right
                }
            }
            .padding()
            
            TabView {
                AddDataView()
                    .tabItem {
                        Label("Add Data", systemImage: "plus.circle").foregroundColor(primaryColor)
                    }
                
                ViewDataView()
                    .tabItem {
                        Label("View Data", systemImage: "list.bullet").foregroundColor(primaryColor)
                    }
                
                UsersTabView()
                    .tabItem {
                        Label("Users", systemImage: "person.crop.circle.badge.plus").foregroundColor(primaryColor)
                    }
            }
        }
        .navigationTitle("Admin Panel")
    }
}


struct UsersTabView: View {
    @Query var users: [UserEntity]
    @State private var showAddUserSheet = false
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            List {
                // Section: Show All Users
                Section(header: Text("All Users")) {
                    ForEach(users) { user in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(user.firstName ?? "Unknown") \(user.lastName ?? "User")")
                                    .font(.headline)
                                    .foregroundColor(isLoggedInUser(user) ? .green : .primary)
                                
                                if isLoggedInUser(user) {
                                    Text("(You)")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .bold()
                                }
                            }
                            Text("Role: \(user.role.capitalized ?? "N/A")")
                                .font(.subheadline)
                            Text("Username: \(user.username ?? "Unknown")")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                        .background(isLoggedInUser(user) ? Color.green.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                    }
                }
                
                // Section: Add New User
                Section {
                    Button(action: {
                        showAddUserSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add New User")
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Users")
            .sheet(isPresented: $showAddUserSheet) {
                UserFormView()
            }
        }
    }
    
    // Helper to check if the given user is the logged-in user
    private func isLoggedInUser(_ user: UserEntity) -> Bool {
        return dataManager.currentUser?.id == user.id
    }
}

struct UserFormView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var role: String = "user"
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let roles = ["admin", "user"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Details")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                }
                
                Section(header: Text("Role")) {
                    Picker("Role", selection: $role) {
                        ForEach(roles, id: \.self) { role in
                            Text(role.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Add New User")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveUser()
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func saveUser() {
        if firstName.isEmpty || lastName.isEmpty || username.isEmpty || password.isEmpty {
            alertMessage = "All fields are required."
            showAlert = true
            return
        }
        
        let success = dataManager.registerUser(firstName: firstName, lastName: lastName, username: username, password: password, role: role)
        if success {
            dismiss()
        } else {
            alertMessage = "Username is already taken."
            showAlert = true
        }
    }
}

struct CreateUserView: View {
    @EnvironmentObject var dataManager: DataManager
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var selectedRole: UserRole = .user // Enum to track selected role
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    enum UserRole: String, CaseIterable, Identifiable {
        case admin = "Admin"
        case user = "User"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        Form {
            // User Information Section
            Section(header: HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.blue)
                Text("Add New User")
                    .font(.headline)
            }) {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 5)
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 5)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 5)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 5)
                
                Picker("Role", selection: $selectedRole) {
                    ForEach(UserRole.allCases) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 5)
            }
            
            // Save Button
            Button(action: createUser) {
                Text("Create User")
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
        .navigationTitle("Create User")
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    private func isFormValid() -> Bool {
        return !firstName.isEmpty &&
        !lastName.isEmpty &&
        !username.isEmpty &&
        !password.isEmpty
    }
    
    private func createUser() {
        let success = dataManager.registerUser(
            firstName: firstName,
            lastName: lastName,
            username: username,
            password: password,
            role: selectedRole.rawValue.lowercased()
        )
        
        if success {
            alertTitle = "Success"
            alertMessage = "User \(username) has been created successfully."
        } else {
            alertTitle = "Error"
            alertMessage = "Failed to create user. Username \(username) might already exist."
        }
        showAlert = true
        clearForm()
    }
    
    private func clearForm() {
        firstName = ""
        lastName = ""
        username = ""
        password = ""
        selectedRole = .user // Default to "User"
    }
}

struct AddDataView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.modelContext) private var context
    @State private var name: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var floors: String = ""
    @State private var rows: String = ""
    @State private var columns: String = ""
    @State private var maxCapacity: String = ""
    @State private var selectedType: ParkingAreaType = .lot // Enum to track selected type
    
    // State to handle the alert
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
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
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.orange)
                    TextField("Rows", text: $rows)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Image(systemName: "line.3.horizontal")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.orange)
                    TextField("Columns", text: $columns)
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
            Alert(title: Text(alertTitle),
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
              let rows = Int(rows),
              let cols = Int(columns),
              let maxCapacity = Int(maxCapacity) else {
            return
        }
        
        // Add based on the selected type (Lot or Building)
        let nearestEntrance = dataManager.entrances.first ?? nil
        if selectedType == .lot {
            do {
                  // Check if a lot with the same name already exists
                  let fetchRequest = FetchDescriptor<LotEntity>(
                      predicate: #Predicate { $0.name == name }
                  )
                  let existingLots = try context.fetch(fetchRequest)
                  
                  if !existingLots.isEmpty {
                      alertMessage = "Parking Lot '\(name)' already exists."
                      alertTitle = "Failed"
                  } else {
                      guard let nearestEntrance = nearestEntrance else {
                          alertMessage = "Nearest entrance is required."
                          alertTitle = "Failed"
                          return
                      }
                      
                      // Create a new LotEntity
                      let newLot = LotEntity(
                          name: name,
                          coordinates: [latitude, longitude],
                          floors: floors,
                          rows: rows,
                          cols: cols,
                          nearestEntrance: nearestEntrance
                      )
                      context.insert(newLot)
                      
                      alertMessage = "Parking Lot '\(name)' added successfully."
                      alertTitle = "Success"
                  }
              } catch {
                  alertMessage = "An error occurred while adding the parking lot."
                  alertTitle = "Error"
              }
            
        } else {
            do {
                  // Check if a lot with the same name already exists
                  let fetchRequest = FetchDescriptor<BuildingEntity>(
                      predicate: #Predicate { $0.name == name }
                  )
                  let existingBuilding = try context.fetch(fetchRequest)
                  
                  if !existingBuilding.isEmpty {
                      alertMessage = "Building '\(name)' already exists."
                      alertTitle = "Failed"
                  } else {
                      guard let nearestEntrance = nearestEntrance else {
                          alertMessage = "Nearest entrance is required."
                          alertTitle = "Failed"
                          return
                      }
                      
                      // Create a new LotEntity
                      let newBuilding = BuildingEntity(
                          name: name,
                          coordinates: [latitude, longitude],
                          floors: floors,
                          rows: rows,
                          cols: cols,
                          nearestEntrance: nearestEntrance
                      )
                      context.insert(newBuilding)
                      
                      alertMessage = "Building '\(name)' added successfully."
                      alertTitle = "Success"
                  }
              } catch {
                  alertMessage = "An error occurred while adding the building."
                  alertTitle = "Error"
              }
            
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
    @State private var selectedLot: LotEntity?
    @State private var selectedBuilding: BuildingEntity?
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
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var floors: String = ""
    @State private var maxCapacity: String = ""
    
    @State private var showDeleteAlert = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    var lot: LotEntity?
    var building: BuildingEntity?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
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
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(alertTitle),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("OK")))}
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
            let fetchRequest = FetchDescriptor<LotEntity>(
                predicate: #Predicate { $0.name == name}
            )
            
            
                do {
                    if try context.fetch(fetchRequest).count > 0 {
                        alertMessage = "Name already exists."
                        alertTitle = "Error"
                    }
                                        
                    guard !name.isEmpty else {
                        alertMessage = "Validate: Name must not be empty."
                        alertTitle = "Error"
                        return
                    }
                                        
                    guard latitude != 0, longitude != 0 else {
                        alertMessage = "Validate: Coordinates should have exactly two non-zero values."
                        alertTitle = "Error"
                        return
                    }
                     
                    guard floors > 0 else {
                        alertMessage = "Validate: Floors must be greater than 0."
                        alertTitle = "Error"
                        return
                    }
                                        
                    guard maxCapacity > 0 else {
                        alertMessage = "Validate: Max Capacity must be greater than 0."
                        alertTitle = "Error"
                        return
                    }
                    
                    // Update the fields
                    lot.name = name
                    lot.coordinates = [latitude, longitude]
                    lot.floors = floors
                    
                    // Save changes to the context
                    try context.save()
                } catch {
                    print("Failed to update lot: \(error)")
                }
        } else if let building = building {
           
            let fetchRequest = FetchDescriptor<BuildingEntity>(
                predicate: #Predicate { $0.name == name }
            )
            
            do {
                if try context.fetch(fetchRequest).count > 0 {
                    alertMessage = "Name already exists."
                    alertTitle = "Error"
                }
                                    
                guard !name.isEmpty else {
                    alertMessage = "Validate: Name must not be empty."
                    alertTitle = "Error"
                    return
                }
                                    
                guard latitude != 0, longitude != 0 else {
                    alertMessage = "Validate: Coordinates should have exactly two non-zero values."
                    alertTitle = "Error"
                    return
                }
                 
                guard floors > 0 else {
                    alertMessage = "Validate: Floors must be greater than 0."
                    alertTitle = "Error"
                    return
                }
                                    
                guard maxCapacity > 0 else {
                    alertMessage = "Validate: Max Capacity must be greater than 0."
                    alertTitle = "Error"
                    return
                }
                
                // Update the fields
                building.name = name
                building.coordinates = [latitude, longitude]
                building.floors = floors
                building.maxCapacity = maxCapacity
                // Save changes to the context
                try context.save()
            } catch {
                print("Failed to update building: \(error)")
            }
            
        }
        
        isPresenting = false
    }
    
    // Delete the lot or building
    private func deleteItem() {
        if let lot = lot {
            do {
            context.delete(lot)
            try context.save()
                    print("Lot '\(lot.name)' deleted successfully.")
            } catch {
                    print("Failed to delete lot: \(error)")
                }
        } else if let building = building {
            do {
                   // Delete the building
                   context.delete(building)
                   // Save changes to persist the deletion
                   try context.save()
                   print("Building '\(building.name)' deleted successfully.")
            } catch {
                print("Failed to delete building: \(error)")
            }
        }
        
        isPresenting = false
    }
}

//#Preview {
//    AdminView()
//        .environmentObject(DataManager.shared)  // Inject DataManager
//}


