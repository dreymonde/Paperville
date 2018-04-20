
public struct Road {
    
    internal init(startLocation: Location, direction: Direction, length: Int, name: String) {
        self.startLocation = startLocation
        self.direction = direction
        self.length = length
        self.name = name
    }
    
    public enum Direction : Int {
        case up = 0
        case down
        case left
        case right
        
        public var toLeft: Direction {
            switch self {
            case .up:
                return .left
            case .left:
                return .down
            case .down:
                return .right
            case .right:
                return .up
            }
        }
        
        public var toRight: Direction {
            switch self {
            case .up:
                return .right
            case .left:
                return .up
            case .down:
                return .left
            case .right:
                return .down
            }
        }
        
        public var opposite: Direction {
            switch self {
            case .up:
                return .down
            case .left:
                return .right
            case .down:
                return .up
            case .right:
                return .left
            }
        }
        
    }
    
    internal var startLocation: Location
    internal var direction: Direction
    public var length: Int
    public var name: String
    
    internal var endLocation: Location {
        return startLocation.advanced(by: length - 1, in: self.direction)
    }
    
    internal var affectedLocationsButStart: [Location] {
        guard length > 1 else {
            return []
        }
        return (1 ... length - 1).map({ startLocation.advanced(by: $0, in: self.direction) })
    }
    
    internal var affectedLocations: [Location] {
        return [startLocation] + affectedLocationsButStart
    }
    
}

public struct Anchor {
    
    internal let road: Road
    internal let location: Location
    
    public init(_ road: Road, location: Location) {
        self.road = road
        self.location = location
    }
    
    internal func roadToLeft(length: Int, name: String) -> Road {
        return Road(startLocation: location, direction: road.direction.toLeft, length: length, name: name)
    }
    
    internal func roadToRight(length: Int, name: String) -> Road {
        return Road(startLocation: location, direction: road.direction.toRight, length: length, name: name)
    }
    
}

extension Road {
    
    public var start: Anchor {
        return Anchor.init(self, location: self.startLocation)
    }
    
    internal var halfLength: Int {
        if length % 2 == 0 {
            return length / 2
        } else {
            return length / 2 + 1
        }
    }
    
    public var center: Anchor {
        let centerBlock = startLocation.advanced(by: length / 2, in: self.direction)
        return Anchor.init(self, location: centerBlock)
    }
    
    public var end: Anchor {
        return Anchor.init(self, location: self.endLocation)
    }
    
    internal func areaToLeft(_ type: AreaType, depth: Int) -> Area {
        return Area(adjacentRoad: self, side: .left, depth: depth, type: type)
    }
    
    internal func areaToRight(_ type: AreaType, depth: Int) -> Area {
        return Area(adjacentRoad: self, side: .right, depth: depth, type: type)
    }
    
    public subscript(offset: Int) -> Anchor {
        return Anchor(self, location: startLocation.advanced(by: offset, in: self.direction))
    }
    
    public subscript(range: ClosedRange<Int>) -> Road {
        let newStart = startLocation.advanced(by: range.lowerBound, in: self.direction)
        let length = range.upperBound - range.lowerBound + 1
        return Road(startLocation: newStart, direction: direction, length: length, name: name)
    }
    
    public var reversed: Road {
        return Road(startLocation: endLocation, direction: direction.opposite, length: length, name: name)
    }
    
}

extension Road.Direction {
    
    public enum Alignment {
        case horizontal, vertical
    }
    
    public var alignment: Alignment {
        switch self {
        case .left, .right:
            return .horizontal
        case .up, .down:
            return .vertical
        }
    }
    
}

extension Road {
    
    public struct Segment {
        let referenceRoad: Road
    }
    
    public var segment: Segment {
        return Segment(referenceRoad: self)
    }
    
}

extension Road.Segment {
    
    public func before(_ road: Road) -> Road {
        precondition(referenceRoad.direction.alignment != road.direction.alignment)
        switch road.direction.alignment {
        case .horizontal:
            return betweenY(y1: referenceRoad.startLocation.y, y2: road.startLocation.y)
        case .vertical:
            return betweenX(x1: referenceRoad.startLocation.x, x2: road.startLocation.x)
        }
    }
    
    public func after(_ road: Road) -> Road {
        precondition(referenceRoad.direction.alignment != road.direction.alignment)
        switch road.direction.alignment {
        case .horizontal:
            return betweenY(y1: road.startLocation.y, y2: referenceRoad.endLocation.advanced(by: 1, in: referenceRoad.direction).y)
        case .vertical:
            return betweenX(x1: road.startLocation.x, x2: referenceRoad.endLocation.advanced(by: 1, in: referenceRoad.direction).x)
        }
    }
    
    private func betweenX(x1: Int, x2: Int) -> Road {
        precondition(referenceRoad.direction.alignment == .horizontal)
        let distance = x2 - x1
        if distance > 1 {
            let start = Location(x: x1, y: referenceRoad.startLocation.y)
            return Road(startLocation: start, direction: .right, length: distance, name: referenceRoad.name)
        } else if distance < -1 {
            let start = Location(x: x1, y: referenceRoad.startLocation.y)
            return Road(startLocation: start, direction: .left, length: -distance, name: referenceRoad.name)
        } else {
            preconditionFailure("Roads are on the same level")
        }
    }
    
    private func betweenY(y1: Int, y2: Int) -> Road {
        precondition(referenceRoad.direction.alignment == .vertical)
        let distance = y2 - y1
        if distance < -1 {
            let start = Location(x: referenceRoad.startLocation.x, y: y1)
            return Road(startLocation: start, direction: .up, length: -distance, name: referenceRoad.name)
        } else if distance > 1 {
            let start = Location(x: referenceRoad.startLocation.x, y: y1)
            return Road(startLocation: start, direction: .down, length: distance, name: referenceRoad.name)
        } else {
            preconditionFailure("Roads are on the same level")
        }
    }
    
    public func between(_ roadOne: Road, and roadTwo: Road) -> Road {
        guard roadOne.direction.alignment == roadTwo.direction.alignment else {
            preconditionFailure("Alignments are not equal")
        }
        switch roadOne.direction.alignment {
        case .horizontal:
            return betweenY(y1: roadOne.startLocation.y, y2: roadTwo.startLocation.y)
        case .vertical:
            return betweenX(x1: roadOne.startLocation.x, x2: roadTwo.startLocation.x)
        }
    }
    
}

extension Road {
    
    public var firstHalf: Road {
        return Road(startLocation: startLocation, direction: direction, length: halfLength, name: name)
    }
    
    public var secondHalf: Road {
        return Road(startLocation: endLocation.advanced(by: -(halfLength - 1), in: direction), direction: direction, length: halfLength, name: name)
    }
    
}

extension Road : Hashable {
    
    public var hashValue: Int {
        return startLocation.hashValue ^ direction.hashValue ^ length.hashValue ^ name.hashValue
    }
    
    public static func ==(lhs: Road, rhs: Road) -> Bool {
        return lhs.startLocation == rhs.startLocation &&
            lhs.direction == rhs.direction &&
            lhs.length == rhs.length &&
            lhs.name == rhs.name
    }
    
}


