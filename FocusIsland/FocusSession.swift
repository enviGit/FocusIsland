//
//  FocusSession.swift
//  FocusIsland
//
//  Created by Paweł Trojański on 18/04/2026.
//

import Foundation
import SwiftData

@Model
final class FocusSession {
    var taskName: String
    var startDate: Date
    var endDate: Date?
    var isFavorite: Bool = false
    
    init(taskName: String, startDate: Date = .now, isFavorite: Bool = false) {
        self.taskName = taskName
        self.startDate = startDate
        self.isFavorite = isFavorite
    }
}
