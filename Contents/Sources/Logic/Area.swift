
public enum AreaType : Int {
    case housing = 0
    case commerce
    case industry
    case park
}

public struct Area {
    
    public enum Side : Int {
        case left = 0
        case right
    }
    
    public var adjacentRoad: Road
    internal var side: Side
    internal var depth: Int
    internal var type: AreaType
    
    internal var directionFromRoad: Road.Direction {
        switch side {
        case .left:
            return adjacentRoad.direction.toLeft
        case .right:
            return adjacentRoad.direction.toRight
        }
    }
    
    internal var affectedLocations: [Location] {
        var blocks: [Location] = []
        for depthLevel in (1 ... depth) {
            let blocksLevel = adjacentRoad.affectedLocations.map({ $0.advanced(by: depthLevel, in: directionFromRoad) })
            blocks.append(contentsOf: blocksLevel)
        }
        return blocks
    }
    
}
