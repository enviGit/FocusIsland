//
//  FocusIslandApp.swift
//  FocusIsland
//
//  Created by Paweł Trojański on 18/04/2026.
//

import SwiftUI
import SwiftData

@main
struct FocusIslandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarManager: StatusBarManager?
    var modelContainer: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        do {
            modelContainer = try ModelContainer(for: FocusSession.self)
            if let container = modelContainer {
                statusBarManager = StatusBarManager(modelContainer: container)
            }
        } catch {
            print("Failed to init SwiftData: \(error)")
        }
    }
}
