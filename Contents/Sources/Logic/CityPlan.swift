
import Darwin

internal struct CityPlan {
    
    internal var blocks: [[City.Block]]
    
    internal var flat: FlattenSequence<[[City.Block]]> {
        return blocks.joined()
    }
    
    var lastValidY: Int {
        return blocks.endIndex - 1
    }
    
    var lastValidX: Int {
        return blocks[0].endIndex - 1
    }
    
    internal func iterate(with perform: (Location, City.Block) -> ()) {
        for (lineOffset, line) in blocks.enumerated() {
            for (blockOffset, block) in line.enumerated() {
                let location = Location(x: blockOffset, y: lineOffset)
                perform(location, block)
            }
        }
    }
    
    internal func find(blocksMatching predicate: (City.Block) -> Bool) -> [Location] {
        var matching: [Location] = []
        for (lineOffset, line) in blocks.enumerated() {
            for (blockOffset, block) in line.enumerated() {
                if predicate(block) {
                    let blockPlace = Location(x: blockOffset, y: lineOffset)
                    matching.append(blockPlace)
                }
            }
        }
        return matching
    }
    
    subscript(location: Location) -> City.Block {
        return blocks[location.y][location.x]
    }
    
}

internal extension CityPlan {
    
    var roadBlocks: [Location] {
        return find(blocksMatching: { $0.isRoad })
    }
    
    var buildings: [Location] {
        return find(blocksMatching: { $0.isBuilding })
    }
    
    var residential: [Location] {
        return find(blocksMatching: { $0 == .residential })
    }
    
    var commercial: [Location] {
        return find(blocksMatching: { $0 == .commercial })
    }
    
    var industrial: [Location] {
        return find(blocksMatching: { $0 == .industrial })
    }
    
    var parks: [Location] {
        return find(blocksMatching: { $0 == .park })
    }
    
    func advance(_ location: Location,
                 inDirection direction: Road.Direction,
                 by offset: Int = 1) -> Location? {
        let advanced = location.advanced(by: offset, in: direction)
        if advanced.x >= 0, advanced.x <= lastValidX,
            advanced.y >= 0, advanced.y <= lastValidY {
            return advanced
        } else {
            return nil
        }
    }
    
}

internal extension CityPlan {
    
    func render() {
        for line in blocks {
            for block in line {
                print(block.rawValue, separator: "", terminator: " ")
            }
            print("")
        }
    }
    
}

extension City.Block {
    
    var isTraversable: Bool {
        return self != .free
    }
    
}

func locationsInWalkingDistance(from location: Location,
                                in plan: CityPlan,
                                maxDistance: Int) -> AnyCollection<Location> {
    var map: [Location : Int] = [:]
    traverse(plan: plan, from: location, comingFrom: nil, stepsLeft: maxDistance, stepsMap: &map)
    return AnyCollection(map.keys)
}

private func traverse(plan: CityPlan,
                      from location: Location,
                      comingFrom incomingDirection: Road.Direction?,
                      stepsLeft: Int,
                      stepsMap: inout [Location : Int]) {
    guard stepsLeft > 0 else {
        return
    }
    if !plan[location].isTraversable {
        return
    }
    let stepsLeft = stepsLeft - 1
    if let previousStepsLeft = stepsMap[location], previousStepsLeft >= stepsLeft {
        return
    }
    stepsMap[location] = stepsLeft
    let directions: [Road.Direction] = [.right, .down, .left, .up].filter({ $0 != incomingDirection })
    for direction in directions {
        if let advancedLocation = plan.advance(location, inDirection: direction) {
            traverse(plan: plan,
                     from: advancedLocation,
                     comingFrom: direction.opposite,
                     stepsLeft: stepsLeft,
                     stepsMap: &stepsMap)
        }
    }
}
