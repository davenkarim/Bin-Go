//
//  Models.swift
//  BinGo
//
//  Created by sam on 14/06/25.
//

// MARK: - Models

import Foundation

/// Represents a detected trash item
struct DetectedTrash {
    let name: String
    let category: String
    let confidence: Float
}

/// Enum for trash categories
enum TrashCategory: String, CaseIterable {
    case organic = "Organic"
    case anorganic = "Anorganic"
    case miscellaneous = "Miscellaneous"
    case unknown = "Unknown"
    
    static func categorize(from className: String) -> TrashCategory {
        let lowercased = className.lowercased()
        
        if lowercased.contains("paper") ||
           lowercased.contains("cardboard") ||
           lowercased.contains("food") ||
           lowercased.contains("organic") {
            return .organic
        }
        
        if lowercased.contains("glass") ||
           lowercased.contains("metal") ||
           lowercased.contains("plastic") {
            return .anorganic
        }
        
        if lowercased.contains("miscellaneous") ||
           lowercased.contains("trash") {
            return .miscellaneous
        }
        
        return .unknown
    }
}
