
struct Building : Hashable {
    
    let location: Location
    let block: City.Block
    
    var hashValue: Int {
        return location.hashValue ^ block.hashValue
    }
    
    static func ==(lhs: Building, rhs: Building) -> Bool {
        return lhs.location == rhs.location && lhs.block == rhs.block
    }
    
}

public struct City {
    
    internal enum Block : Character {
        case free = "∙"
        case roadStart = "s"
        case road = "▴"
        case roadEnd = "e"
        case residential = "R"
        case commercial = "C"
        case industrial = "I"
        case park = "P"
        
        internal var isRoad: Bool {
            switch self {
            case .road, .roadStart, .roadEnd:
                return true
            default:
                return false
            }
        }
        
        internal var isBuilding: Bool {
            switch self {
            case .commercial, .residential, .industrial:
                return true
            default:
                return false
            }
        }
        
    }
    
    private static func block(of areaType: AreaType) -> Block {
        switch areaType {
        case .housing:
            return .residential
        case .commerce:
            return .commercial
        case .industry:
            return .industrial
        case .park:
            return .park
        }
    }
    
    public init(side: Int) {
        self.side = side
    }
    
    public let side: Int
    public var areas: [Area] = []
    public var roads: [Road] = []
    
    internal var plan: CityPlan {
        var blocks = Array(repeating: Array(repeating: Block.free, count: side), count: side)
        
        for area in areas {
            let affectedLocations = area.affectedLocations
            for block in affectedLocations {
                blocks[block.y][block.x] = City.block(of: area.type)
            }
        }
        
        for road in roads {
            blocks[road.startLocation.y][road.startLocation.x] = .roadStart
            let affectedLocations = road.affectedLocationsButStart
            for block in affectedLocations {
                blocks[block.y][block.x] = .road
            }
            let end = road.endLocation
            blocks[end.y][end.x] = .roadEnd
        }
        return CityPlan(blocks: blocks)
    }
    
}

extension Area : Equatable {
    
    public static func == (lhs: Area, rhs: Area) -> Bool {
        return lhs.affectedLocations == rhs.affectedLocations && lhs.type == rhs.type
    }
    
}

extension City : Equatable {
    
    public static func == (lhs: City, rhs: City) -> Bool {
        return lhs.roads == rhs.roads && lhs.areas == rhs.areas && lhs.side == rhs.side
    }
    
}
