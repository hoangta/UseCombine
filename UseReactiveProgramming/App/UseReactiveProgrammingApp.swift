//
//  UseReactiveProgrammingApp.swift
//  UseReactiveProgramming
//
//  Created by Hoang Ta on 8/7/24.
//

import SwiftUI
import SwiftData

@main
struct UseReactiveProgrammingApp: App {
    var body: some Scene {
        WindowGroup {
//            BackPressureView()
            Debugging()
                .buttonStyle(.main)
                .preferredColorScheme(.light)
        }
    }
}
