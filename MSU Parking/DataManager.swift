//
//  DataManager.swift
//  MSU Parking
//
//  Created by mrrobot on 25/11/24.
//

import Foundation
import SwiftData
import Combine

class DataManager: ObservableObject {
    @Published var regions: [RegionEntity] = []
    @Published var entrances: [EntranceEntity] = []
    @Published var lots: [LotEntity] = []
    @Published var users: [UserEntity] = []
    @Published var buildings: [BuildingEntity] = []
    @Published var currentUser: UserEntity? = nil
    
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
        Task {
            await self.loadTestData()
        }
    }
    
    private func loadTestData() async {
        do {
            // Fetch existing data
            self.regions = try context.fetch(FetchDescriptor<RegionEntity>())
            self.entrances = try context.fetch(FetchDescriptor<EntranceEntity>())
            self.lots = try context.fetch(FetchDescriptor<LotEntity>())
            self.users = try context.fetch(FetchDescriptor<UserEntity>())
            
            // Populate test data if necessary
            if regions.isEmpty { await populateRegions() }
            if entrances.isEmpty { await populateEntrances() }
            if lots.isEmpty { await populateLots() }
            if users.isEmpty { await populateUsers() }
        } catch {
            print("Error loading data: \(error.localizedDescription)")
        }
    }
    
    private func populateRegions() async {
        let north = RegionEntity(name: "North")
        let south = RegionEntity(name: "South")
        let east = RegionEntity(name: "East")
        let west = RegionEntity(name: "West")
        
        await MainActor.run {
            self.regions = [north, south, east, west]
            regions.forEach { context.insert($0) }
        }
    }
    
    private func populateEntrances() async {
        await MainActor.run {
            for i in 0...5 {
                let entrance = EntranceEntity(
                    name: "North Hall-\(i)",
                    coordinates: [123.0 + Double(i), 456.0 + Double(i)],
                    region: regions.first(where: { $0.name == "North" })!
                )
                entrances.append(entrance)
                context.insert(entrance)
            }
        }
    }
    
    private func populateLots() async {
        await MainActor.run {
            for i in 0...5 {
                let lot = LotEntity(
                    name: "Lot-\(i)",
                    coordinates: [123.0 + Double(i), 456.0 + Double(i)],
                    floors: 3,
                    rows: 5,
                    cols: 5,
                    nearestEntrance: entrances.first!
                )
                lots.append(lot)
                context.insert(lot)
            }
        }
    }
    
    private func populateBuildings() async {
        await MainActor.run {
            for i in 0...3 {
                let building = BuildingEntity(name: "building-\(i)", coordinates: [123.0 + Double(i), 456.0 + Double(i)], floors: 3 + i, rows: 5 + i, cols: 5 + i, nearestEntrance: entrances.first!)
                buildings.append(building)
            }
        }
    }
    
    private func populateUsers() async {
        let admin = UserEntity(firstName: "Admin", lastName: "Admin", username: "admin", password: "admin123", role: "admin")
        let user = UserEntity(firstName: "User", lastName: "User", username: "user", password: "user123", role: "user")
        
        await MainActor.run {
            self.users = [admin, user]
            users.forEach { context.insert($0) }
        }
    }
    
    func authenticateUser(username: String, password: String) -> UserEntity? {
        do {
            // Fetch users matching the username
            let fetchedUsers = try context.fetch(
                FetchDescriptor<UserEntity>(
                    predicate: #Predicate { $0.username == username && $0.password == password }
                )
            )
            
            if let user = fetchedUsers.first {
                currentUser = user
                return user
            }
        } catch {
            print("Error during authentication: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    
    func logout() {
        currentUser = nil
    }
    
    
    func isLoggedIn() -> Bool {
        return currentUser != nil
    }
    
    
    func registerUser(firstName: String, lastName: String, username: String, password: String, role: String) -> Bool {
        // Check if the username is already taken
        do {
            let existingUsers = try context.fetch(
                FetchDescriptor<UserEntity>(
                    predicate: #Predicate { $0.username == username }
                )
            )
            
            if !existingUsers.isEmpty {
                print("Username already taken.")
                return false
            }
            
            
            let newUser = UserEntity(
                firstName: firstName,
                lastName: lastName,
                username: username,
                password: password,
                role: role
            )
            
            context.insert(newUser)
            return true
        } catch {
            print("Error during user registration: \(error.localizedDescription)")
            return false
        }
    }
}
