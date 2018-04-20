
import Foundation

struct Fullness {
    
    var n: UInt
    let outOf: UInt
    
    var floatingValue: Float {
        guard outOf > 0 else {
            return 0
        }
        return 0.25 + 0.75 * (Float(n) / Float(outOf))
    }
    
    var isFull: Bool {
        return n == outOf
    }
    
}

struct Census {
    
    let plan: CityPlan
    
    static let factoryJobs = 3
    
    var residential: [Location] = []
    var commercial: [Location] = []
    var industrial: [Location] = []
    
    var workersNeeded: [(Location, UInt)] {
        return commercial.map({ ($0, 1) })
            + industrial.map({ ($0, UInt(Census.factoryJobs)) }).flatMap({ Array(repeating: $0, count: Census.factoryJobs) })
    }
    
    init(plan: CityPlan) {
        self.plan = plan
        plan.iterate { (location, block) in
            switch block {
            case .residential:
                residential.append(location)
            case .commercial:
                commercial.append(location)
            case .industrial:
                industrial.append(location)
            default:
                return
            }
        }
    }
    
    var residentialsTotal: Int {
        return residential.count
    }
    
    var workPlacesTotal: Int {
        return (commercial.count + (industrial.count * 3))
    }
    
    var economicBalance: Float {
        let residentialsTotal = max(self.residentialsTotal, 1)
        let workPlacesTotal = max(self.workPlacesTotal, 1)
        let ratio: Float
        if residentialsTotal >= workPlacesTotal {
            ratio = Float(workPlacesTotal) / Float(residentialsTotal)
        } else {
            ratio = Float(residentialsTotal) / Float(workPlacesTotal)
        }
        return ratio
    }
    
}

struct Distribution {
    
    let census: Census
    let fullnessMap: [Location : Fullness]
    let analysisMap: [Location : ComfortScoreReport]
    
    init(census: Census) {
        self.census = census
        self.fullnessMap = Distribution.fullnessMap(from: census)
        var analyzes: [Location : ComfortScoreReport] = [:]
        for residential in census.residential {
            if let fullness = fullnessMap[residential] {
                analyzes[residential] = ComfortScoreReport(location: residential,
                                                           plan: census.plan,
                                                           fullness: fullness)
            }
        }
        self.analysisMap = analyzes
    }
    
    init(plan: CityPlan) {
        self.init(census: Census.init(plan: plan))
    }
    
    static func fullnessMap(from census: Census) -> [Location : Fullness] {
        var residentialsTotal = UInt(census.residentialsTotal)
        var workPlacesTotal = UInt(census.workPlacesTotal)
        
        var fullness: [Location : Fullness] = [:]
        
        for residential in census.residential.shuffled() {
            if workPlacesTotal > 0 {
                workPlacesTotal -= 1
                fullness[residential] = Fullness(n: 1, outOf: 1)
            } else {
                fullness[residential] = Fullness(n: 0, outOf: 1)
            }
        }
        
        for (location, workersNeeded) in census.workersNeeded.shuffled() {
            if residentialsTotal > 0 {
                residentialsTotal -= 1
                var currentFullness = fullness[location, default: Fullness(n: 0, outOf: workersNeeded)]
                currentFullness.n += 1
                fullness[location] = currentFullness
            } else {
                if fullness[location] == nil {
                    fullness[location] = Fullness(n: 0, outOf: workersNeeded)
                }
            }
        }
        
        return fullness
    }
    
    func averageComfortScoreFloat() -> Float {
        let count = analysisMap.count
        guard count > 0 else {
            return 0
        }
        let sum = analysisMap.values.reduce(into: 0, { $0 += $1.comfortScoreFloat })
        return sum / Float(analysisMap.count)
    }
    
    func averageComfortScore() -> Int {
        return Int(100 * averageComfortScoreFloat())
    }
    
}

internal struct ComfortScoreReport {
    
    static let radius = 7
    
    let location: Location
    
    let commercialSpaces: Int
    let neighbors: Int
    let factories: Int
    let parkPresence: Bool
    let fullness: Fullness
    let walkableLocations: [Location : City.Block]
    
    init(location: Location, plan: CityPlan, fullness: Fullness) {
        self.location = location
        
        let locations = locationsInWalkingDistance(from: location, in: plan, maxDistance: ComfortScoreReport.radius)
        
        var walkableLocations: [Location : City.Block] = [:]
        var commercialSpaces = 0
        var neighbors = 0
        var factories = 0
        var parkPresence = false
        
        for walkableLocation in locations {
            let block = plan[walkableLocation]
            walkableLocations[walkableLocation] = block
            switch block {
            case .commercial:
                commercialSpaces += 1
            case .residential:
                neighbors += 1
            case .industrial:
                factories += 1
            case .park:
                parkPresence = true
            default:
                break
            }
        }
        
        self.walkableLocations = walkableLocations
        self.commercialSpaces = commercialSpaces
        self.neighbors = neighbors
        self.factories = factories
        self.parkPresence = parkPresence
        self.fullness = fullness
    }
    
    var commercialModifier: Float {
        if commercialSpaces >= 6 {
            return 1.0
        } else {
            return 0.7 + 0.3 * (Float(commercialSpaces) / 6)
        }
    }
    
    var neighborsModifier: Float {
        if neighbors >= 6 {
            return 1.0
        } else {
            return 0.7 + 0.3 * (Float(neighbors) / 6)
        }
    }
    
    var industryModifier: Float {
        if factories == 0 {
            return 1.0
        } else {
            return pow(0.9, Float(factories))
        }
    }
    
    var parkModifier: Float {
        if parkPresence {
            return 1.0
        } else {
            return 0.75
        }
    }
    
    var employmentModifier: Float {
        if fullness.n == fullness.outOf {
            return 1.0
        } else {
            return 0.25
        }
    }
    
    var comfortScoreFloat: Float {
        return 1.0 * commercialModifier * neighborsModifier * industryModifier * parkModifier * employmentModifier
    }
    
    var comfortScore: Int {
        return Int(100 * comfortScoreFloat)
    }
    
}

extension MutableCollection {
    
    /// courtesy of Nate Cook
    internal mutating func shuffle() {
        let count = self.count
        guard count > 1 else { return }
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: count, to: 1, by: -1)) {
            let distance: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard distance != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: distance)
            self.swapAt(firstUnshuffled, i)
        }
    }
    
}

extension Sequence {
    
    internal func shuffled() -> [Iterator.Element] {
        var shuffling = Array(self)
        shuffling.shuffle()
        return shuffling
    }
    
}

extension Fullness : CustomStringConvertible {
    var description: String {
        return "\(n) / \(outOf)"
    }
}
