//
//  MSU_ParkingApp.swift
//  MSU Parking
//
//  Created by Zain Ul Abidin on 10/22/24.
//

import SwiftUI
import SwiftData

@main
struct MSU_ParkingApp: App {
    @State private var container: ModelContainer = try! ModelContainer(for: RegionEntity.self, EntranceEntity.self, LotEntity.self, UserEntity.self, BuildingEntity.self)

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(DataManager(context: container.mainContext))
                .modelContainer(container)
//            LoginView().environmentObject(DataManager.shared)
        }
    }
}
