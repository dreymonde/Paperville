
public struct Location {
    public var x: Int
    public var y: Int
    
    public func advanced(by offset: Int, in direction: Road.Direction) -> Location {
        switch direction {
        case .up:
            return Location(x: x, y: y - offset)
        case .down:
            return Location(x: x, y: y + offset)
        case .left:
            return Location(x: x - offset, y: y)
        case .right:
            return Location(x: x + offset, y: y)
        }
    }
    
    public func squaredDistance(to location: Location) -> Int {
        let xdist = self.x - location.x
        let xdistsq = xdist * xdist
        let ydist = self.y - location.y
        let ydistsq = ydist * ydist
        return xdistsq + ydistsq
    }
    
    public func isWithinDistance(of distance: Int, from location: Location) -> Bool {
        let squaredMargin = distance * distance
        return squaredDistance(to: location) <= squaredMargin
    }
    
}

extension Location : CustomStringConvertible {
    public var description: String {
        return "[\(x), \(y)]"
    }
}

extension Location : Hashable {
    public static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    public var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
}
