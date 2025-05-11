//
//  Item.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 11.05.2025.
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
