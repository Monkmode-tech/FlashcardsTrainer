//
//  FlashcardsTrainerApp.swift
//  FlashcardsTrainer
//
//  Created by Caleb Tetteh on 10/26/25.
//

import SwiftUI

@main
struct FlashcardsTrainerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Card.self)
        }
    }
}
