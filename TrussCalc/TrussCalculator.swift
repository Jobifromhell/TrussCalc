import Foundation

struct TrussCalculator {
    static func availableTrusses(from trussList: [TrussElement]) -> [TrussElement] {
        let stock = UserDefaults.standard.dictionary(forKey: "trussStock") as? [String: Bool] ?? [:]
        return trussList.filter { stock[$0.name, default: true] }
    }
    
    static func adjustDimensions(length: Double, width: Double?, height: Double, trussList: [TrussElement]) -> (Double, Double?, Double) {
        let availableLengths = availableTrusses(from: trussList).filter { $0.type == .straight }.map { $0.length! }.sorted(by: >)
        
        func adjustDimension(_ dimension: Double) -> Double {
            var remaining = dimension
            var adjustedDimension = 0.0
            for trussLength in availableLengths {
                while remaining >= trussLength {
                    adjustedDimension += trussLength
                    remaining -= trussLength
                }
            }
            if remaining > 0, let smallestTruss = availableLengths.last {
                adjustedDimension += smallestTruss
            }
            return adjustedDimension
        }
        
        let adjustedLength = adjustDimension(length)
        let adjustedWidth = width.map { adjustDimension($0) }
        let adjustedHeight = adjustDimension(height)
        
        return (adjustedLength, adjustedWidth, adjustedHeight)
    }
    
    static func calculateAutoportee(length: Double, width: Double, height: Double, trussList: [TrussElement], selectedTruss: inout [TrussElement], trussCount: inout [String: Int], totalWeight: inout Double, totalVolume: inout Double, totalPins: inout Int, volumeMargin: Double = 0.1) {
        let availableTrusses = availableTrusses(from: trussList)
        selectedTruss = []
        trussCount = [:]
        totalWeight = 0.0
        totalVolume = 0.0
        totalPins = 0
        
        // Adjust dimensions to the nearest possible values based on available truss lengths
        let (adjustedLength, adjustedWidth, adjustedHeight) = adjustDimensions(length: length, width: width, height: height, trussList: availableTrusses)
        
        // Deduct 1 meter for each dimension to account for 4 corners (each corner 0.5m)
        let effectiveLength = adjustedLength - 1.0
        let effectiveWidth = adjustedWidth! - 1.0
        let effectiveHeight = adjustedHeight - 0.5
        
        // Calculate horizontal trusses (top perimeter)
        calculateTrussesForDimension(dimension: effectiveLength, quantity: 2, trussList: availableTrusses, selectedTruss: &selectedTruss, trussCount: &trussCount, totalPins: &totalPins)
        calculateTrussesForDimension(dimension: effectiveWidth, quantity: 2, trussList: availableTrusses, selectedTruss: &selectedTruss, trussCount: &trussCount, totalPins: &totalPins)
        
        // Calculate vertical trusses (legs)
        calculateTrussesForDimension(dimension: effectiveHeight, quantity: 4, trussList: availableTrusses, selectedTruss: &selectedTruss, trussCount: &trussCount, totalPins: &totalPins)
        // Add corners and bases
        if let corner = availableTrusses.first(where: { $0.type == .corner3Way }) {
            addTrussToCount(truss: corner, quantity: 4, trussCount: &trussCount, selectedTruss: &selectedTruss, totalPins: &totalPins)
        }
        if let base = availableTrusses.first(where: { $0.type == .base }) {
            addTrussToCount(truss: base, quantity: 4, trussCount: &trussCount, selectedTruss: &selectedTruss, totalPins: &totalPins)
        }
        
        // Calculate total weight and volume
        for (key, quantity) in trussCount {
            if let element = availableTrusses.first(where: { "\($0.name) - \($0.length ?? 0)m" == key }) {
                totalWeight += element.weight * Double(quantity)
                totalVolume += (element.length ?? 0.0) * element.width * element.height * Double(quantity)
            }
        }
        
        // Add volume margin
        totalVolume *= (1 + volumeMargin)
    }
    
    static func calculateArche(length: Double, height: Double, trussList: [TrussElement], selectedTruss: inout [TrussElement], trussCount: inout [String: Int], totalWeight: inout Double, totalVolume: inout Double, totalPins: inout Int, volumeMargin: Double = 0.1) {
        let availableTrusses = availableTrusses(from: trussList)
        selectedTruss = []
        trussCount = [:]
        totalWeight = 0.0
        totalVolume = 0.0
        totalPins = 0
        
        // Adjust dimensions to the nearest possible values based on available truss lengths
        let (adjustedLength, _, adjustedHeight) = adjustDimensions(length: length, width: nil, height: height, trussList: availableTrusses)
        
        // Deduct 0.5 meter for length and height to account for 2 corners (each corner 0.5m)
        let effectiveLength = adjustedLength - 1.0
        let effectiveHeight = adjustedHeight - 1.0
        
        // Calculate horizontal trusses (top)
        calculateTrussesForDimension(dimension: effectiveLength, quantity: 1, trussList: availableTrusses, selectedTruss: &selectedTruss, trussCount: &trussCount, totalPins: &totalPins)
        
        // Calculate vertical trusses (legs)
        calculateTrussesForDimension(dimension: effectiveHeight, quantity: 2, trussList: availableTrusses, selectedTruss: &selectedTruss, trussCount: &trussCount, totalPins: &totalPins)
        
        // Add corners and bases
        if let corner = availableTrusses.first(where: { $0.type == .corner2Way }) {
            addTrussToCount(truss: corner, quantity: 2, trussCount: &trussCount, selectedTruss: &selectedTruss, totalPins: &totalPins)
        }
        if let base = availableTrusses.first(where: { $0.type == .base }) {
            addTrussToCount(truss: base, quantity: 2, trussCount: &trussCount, selectedTruss: &selectedTruss, totalPins: &totalPins)
        }
        
        // Calculate total weight and volume
        for (key, quantity) in trussCount {
            if let element = availableTrusses.first(where: { "\($0.name) - \($0.length ?? 0)m" == key }) {
                totalWeight += element.weight * Double(quantity)
                totalVolume += (element.length ?? 0.0) * element.width * element.height * Double(quantity)
            }
        }
        
        // Add volume margin
        totalVolume *= (1 + volumeMargin)
    }
    
    static func calculateTrussesForDimension(dimension: Double, quantity: Int, trussList: [TrussElement], selectedTruss: inout [TrussElement], trussCount: inout [String: Int], totalPins: inout Int) {
        var remainingLength = dimension
        let sortedTrusses = trussList.filter { $0.type == .straight }.sorted(by: { $0.length! > $1.length! })
        
        while remainingLength > 0 {
            guard let truss = sortedTrusses.first(where: { $0.length! <= remainingLength }) else {
                // If no truss is short enough to fit the remaining length, break the loop
                break
            }
            addTrussToCount(truss: truss, quantity: quantity, trussCount: &trussCount, selectedTruss: &selectedTruss, totalPins: &totalPins)
            remainingLength -= truss.length!
        }
        
        // Handle case where remainingLength is not zero
        if remainingLength > 0 {
            // Add the smallest truss available to cover the remaining length
            if let smallestTruss = sortedTrusses.last {
                addTrussToCount(truss: smallestTruss, quantity: quantity, trussCount: &trussCount, selectedTruss: &selectedTruss, totalPins: &totalPins)
            }
        }
    }
    
    static func addTrussToCount(truss: TrussElement, quantity: Int, trussCount: inout [String: Int], selectedTruss: inout [TrussElement], totalPins: inout Int) {
        let key = "\(truss.name) - \(truss.length ?? 0)m"
        if let currentCount = trussCount[key] {
            trussCount[key] = currentCount + quantity
        } else {
            trussCount[key] = quantity
        }
        for _ in 1...quantity {
            selectedTruss.append(truss)
            totalPins += truss.pins
        }
    }
}
