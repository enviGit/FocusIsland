//
//  AppState.swift
//  FocusIsland
//
//  Created by Paweł Trojański on 18/04/2026.
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isHovered = false
    @Published var isPopoverOpen = false
    @Published var isActive = false
    @Published var secondsElapsed: Int = 0
    @Published var taskName = ""
    @Published var currentSessionStart: Date?
    
    private var timer: Timer?
    
    func startTimer(task: String) {
        taskName = task
        isActive = true
        currentSessionStart = Date()
        secondsElapsed = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.secondsElapsed += 1
        }
        
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    func stopTimer() {
            isActive = false
            timer?.invalidate()
            timer = nil
            currentSessionStart = nil
        }
    
    var formattedTime: String {
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
