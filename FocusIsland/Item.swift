//
//  Item.swift
//  FocusIsland
//
//  Created by Paweł Trojański on 18/04/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
