//
//  Item.swift
//  SahinApp
//
//  Enhanced Item model for better inventory management
//

import Foundation
import Firebase

struct Item: Codable {
    var id: String
    var name: String
    var quantity: Int
    var unit: String // e.g., "pieces", "kg", "liters"
    var category: String
    var storageLocation: String
    var expirationDate: Date?
    var dateAdded: Date
    var dateModified: Date
    var notes: String?
    var imageURL: String?
    var lowStockThreshold: Int
    var isLowStock: Bool {
        return quantity <= lowStockThreshold
    }
    
    // Computed property for days until expiration
    var daysUntilExpiration: Int? {
        guard let expiration = expirationDate else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: expiration)
        return components.day
    }
    
    // Computed property for expiration status
    var expirationStatus: ExpirationStatus {
        guard let days = daysUntilExpiration else { return .noDate }
        if days < 0 { return .expired }
        if days <= 3 { return .expiringSoon }
        if days <= 7 { return .expiringThisWeek }
        return .good
    }
    
    enum ExpirationStatus {
        case expired
        case expiringSoon
        case expiringThisWeek
        case good
        case noDate
        
        var color: UIColor {
            switch self {
            case .expired: return .red
            case .expiringSoon: return .orange
            case .expiringThisWeek: return .yellow
            case .good: return .green
            case .noDate: return .gray
            }
        }
        
        var description: String {
            switch self {
            case .expired: return "Expired"
            case .expiringSoon: return "Expires Soon"
            case .expiringThisWeek: return "Expires This Week"
            case .good: return "Good"
            case .noDate: return "No Date"
            }
        }
    }
    
    init(id: String = UUID().uuidString,
         name: String,
         quantity: Int = 1,
         unit: String = "pieces",
         category: String = "Other",
         storageLocation: String,
         expirationDate: Date? = nil,
         dateAdded: Date = Date(),
         dateModified: Date = Date(),
         notes: String? = nil,
         imageURL: String? = nil,
         lowStockThreshold: Int = 5) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.storageLocation = storageLocation
        self.expirationDate = expirationDate
        self.dateAdded = dateAdded
        self.dateModified = dateModified
        self.notes = notes
        self.imageURL = imageURL
        self.lowStockThreshold = lowStockThreshold
    }
    
    // Convert to Firebase dictionary
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "name": name,
            "quantity": quantity,
            "unit": unit,
            "category": category,
            "storageLocation": storageLocation,
            "dateAdded": dateAdded.timeIntervalSince1970,
            "dateModified": dateModified.timeIntervalSince1970,
            "lowStockThreshold": lowStockThreshold
        ]
        
        if let expiration = expirationDate {
            dict["expirationDate"] = expiration.timeIntervalSince1970
        }
        
        if let notes = notes {
            dict["notes"] = notes
        }
        
        if let imageURL = imageURL {
            dict["imageURL"] = imageURL
        }
        
        return dict
    }
    
    // Create from Firebase snapshot
    static func fromSnapshot(_ snapshot: DataSnapshot) -> Item? {
        guard let dict = snapshot.value as? [String: Any] else { return nil }
        
        let id = dict["id"] as? String ?? snapshot.key
        guard let name = dict["name"] as? String else { return nil }
        let quantity = dict["quantity"] as? Int ?? 1
        let unit = dict["unit"] as? String ?? "pieces"
        let category = dict["category"] as? String ?? "Other"
        let storageLocation = dict["storageLocation"] as? String ?? ""
        let lowStockThreshold = dict["lowStockThreshold"] as? Int ?? 5
        
        var expirationDate: Date?
        if let expTimestamp = dict["expirationDate"] as? TimeInterval {
            expirationDate = Date(timeIntervalSince1970: expTimestamp)
        }
        
        var dateAdded = Date()
        if let addedTimestamp = dict["dateAdded"] as? TimeInterval {
            dateAdded = Date(timeIntervalSince1970: addedTimestamp)
        }
        
        var dateModified = Date()
        if let modifiedTimestamp = dict["dateModified"] as? TimeInterval {
            dateModified = Date(timeIntervalSince1970: modifiedTimestamp)
        }
        
        let notes = dict["notes"] as? String
        let imageURL = dict["imageURL"] as? String
        
        return Item(
            id: id,
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            storageLocation: storageLocation,
            expirationDate: expirationDate,
            dateAdded: dateAdded,
            dateModified: dateModified,
            notes: notes,
            imageURL: imageURL,
            lowStockThreshold: lowStockThreshold
        )
    }
}

// Category definitions
struct ItemCategory {
    static let categories = [
        "Dairy",
        "Meat & Seafood",
        "Produce",
        "Bakery",
        "Frozen",
        "Pantry",
        "Beverages",
        "Snacks",
        "Condiments",
        "Other"
    ]
    
    static let categoryIcons: [String: String] = [
        "Dairy": "🥛",
        "Meat & Seafood": "🥩",
        "Produce": "🥬",
        "Bakery": "🍞",
        "Frozen": "🧊",
        "Pantry": "🥫",
        "Beverages": "🥤",
        "Snacks": "🍿",
        "Condiments": "🧂",
        "Other": "📦"
    ]
}

