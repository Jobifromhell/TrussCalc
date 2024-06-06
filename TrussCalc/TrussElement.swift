import Foundation

struct TrussElement: Identifiable {
    let id = UUID()
    let name: String
    let length: Double?  // Length in meters (if applicable)
    let weight: Double   // Weight in kilograms
    let width: Double    // Width in meters (cross-section)
    let height: Double   // Height in meters (cross-section)
    let type: TrussType
    let pins: Int  // Number of pins required
}

enum TrussType {
    case straight
    case corner2Way
    case corner3Way
    case corner4Way
    case base
    case plate
}

let eurotrussFD34: [TrussElement] = [
    // Straight elements
    TrussElement(name: "FD34-025", length: 0.25, weight: 2, width: 0.29, height: 0.29, type: .straight, pins: 4),
//    TrussElement(name: "FD34-029", length: 0.29, weight: 2.5, width: 0.29, height: 0.29, type: .straight, pins: 4),
    TrussElement(name: "FD34-050", length: 0.50, weight: 3.5, width: 0.29, height: 0.29, type: .straight, pins: 4),
    TrussElement(name: "FD34-075", length: 0.75, weight: 5, width: 0.29, height: 0.29, type: .straight, pins: 4),
    TrussElement(name: "FD34-100", length: 1.00, weight: 6.3, width: 0.29, height: 0.29, type: .straight, pins: 4),
    TrussElement(name: "FD34-150", length: 1.50, weight: 8.1, width: 0.29, height: 0.29, type: .straight, pins: 4),
    TrussElement(name: "FD34-200", length: 2.00, weight: 10.5, width: 0.29, height: 0.29, type: .straight, pins: 4),
    TrussElement(name: "FD34-250", length: 2.50, weight: 13.0, width: 0.29, height: 0.29, type: .straight, pins: 4),
    TrussElement(name: "FD34-300", length: 3.00, weight: 15.0, width: 0.29, height: 0.29, type: .straight, pins: 4),
    TrussElement(name: "FD34-350", length: 3.50, weight: 16.5, width: 0.29, height: 0.29, type: .straight, pins: 4),

    TrussElement(name: "FD34-400", length: 4.00, weight: 19.5, width: 0.29, height: 0.29, type: .straight, pins: 4),
    
    // Corner elements
    TrussElement(name: "FD34-L90 (90°)", length: 0.5, weight: 5.0, width: 0.29, height: 0.29, type: .corner2Way, pins: 8), // Corner 2-way example
    TrussElement(name: "FD34 3 WAY CORNER 90˚ + DOWN", length: 0.5, weight: 5.0,width: 0.5, height: 0.5, type: .corner3Way, pins: 12),
//    TrussElement(name: "FD34 3 WAY + DOWN", length: 0.5, weight: 5.0,width: 0.5, height: 0.5, type: .corner3Way, pins: 12),
//    TrussElement(name: “FD34-C4”, length: nil, weight: 3.5, width: 0.29, height: 0.29, type: .corner4Way, pins: 16),   // Corner 4-way example
    // Base and plate elements
    TrussElement(name: "FD34-Base", length: 0.8, weight: 80, width: 0.8, height: 0.10, type: .base, pins: 4),      // Base example
//    TrussElement(name: "FD34-Plate", length: nil, weight: 4.0, width: 0.30, height: 0.30, type: .plate, pins: 4)     // Plate example
]
