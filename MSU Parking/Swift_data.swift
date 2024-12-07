//
//  Swift_data.swift
//  MSU Parking
//
//  Created by mrrobot on 25/11/24.
//

import Foundation
import SwiftData
import Combine


@Model
final class RegionEntity {
    @Attribute(.unique) var name: String  // Ensure uniqueness in the database
    init(name: String) {
        self.name = name
    }
}

@Model
final class EntranceEntity {
    var name: String
    var coordinates: [Double]
    var region: RegionEntity
    
    init(name: String, coordinates: [Double], region: RegionEntity) {
        self.name = name
        self.coordinates = coordinates
        self.region = region
    }
}

@Model
final class LotEntity {
    var name: String
    var coordinates: [Double]
    var floors: Int
    var rows: Int
    var cols: Int
    var nearestEntrance: EntranceEntity
    
    var parkingSpots: [[[Bool]]] // Not persisted, this will be derived logic.
    var availableSpots: Int {
        maxCapacity - occupiedSpots
    }
    var maxCapacity: Int {
        floors * rows * cols
    }
    var occupiedSpots: Int {
        parkingSpots.flatMap { $0.flatMap { $0.filter { $0 } } }.count
    }
    
    init(name: String, coordinates: [Double], floors: Int, rows: Int, cols: Int, nearestEntrance: EntranceEntity) {
        self.name = name
        self.coordinates = coordinates
        self.floors = floors
        self.rows = rows
        self.cols = cols
        self.nearestEntrance = nearestEntrance
        
        // Initialize parking spots
        self.parkingSpots = Array(
            repeating: Array(
                repeating: Array(repeating: false, count: cols),
                count: rows
            ),
            count: floors
        )
    }
}

@Model
class BuildingEntity {
    var name: String = ""
    var coordinates: [Double] = []
    var floors: Int = 0
    var cols: Int = 0
    var rows: Int = 0
    var maxCapacity: Int = 0
    var availableSpots: Int = 0
    var nearestEntrance: EntranceEntity
    var parkingSpots: [[[Bool]]]

    init (name: String, coordinates: [Double], floors: Int, rows: Int, cols: Int,nearestEntrance: EntranceEntity) {
        self.name = name
        self.coordinates = coordinates
        self.floors = floors
        self.maxCapacity = floors * rows * cols
        self.availableSpots = floors * rows * cols
        self.nearestEntrance = nearestEntrance
        self.parkingSpots = Array(
            repeating: Array(
                repeating: Array(repeating: false, count: rows),
                count: cols
            ),
            count: floors
        )
    }
}

@Model
final class UserEntity {
    var firstName: String
    var lastName: String
    var username: String
    var password: String
    var role: String
    
    init(firstName: String, lastName: String, username: String, password: String, role: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
        self.role = role
    }
}



