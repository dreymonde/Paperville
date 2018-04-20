import PlaygroundSupport

struct MappingError : Error {
    let key: String
}

extension Assessment {
    public var status: PlaygroundPage.AssessmentStatus {
        switch self {
        case .pass(let message):
            return .pass(message: message)
        case .fail(let hints, let solution):
            return .fail(hints: hints, solution: solution)
        }
    }
}

extension Location {
    
    func playgroundValue() -> PlaygroundValue {
        return .dictionary([
            "x": .integer(x),
            "y": .integer(y),
            ])
    }
    
    init(playgroundValue: PlaygroundValue) throws {
        guard case let .dictionary(dict) = playgroundValue else {
            throw MappingError(key: "top")
        }
        guard case let .integer(x)? = dict["x"] else {
            throw MappingError(key: "x")
        }
        guard case let .integer(y)? = dict["y"] else {
            throw MappingError(key: "y")
        }
        self.init(x: x, y: y)
    }
    
}

extension Road {
    
    func playgroundValue() -> PlaygroundValue {
        return .dictionary([
            "start": startLocation.playgroundValue(),
            "direction": .integer(direction.rawValue),
            "length": .integer(length),
            "name": .string(name)
        ])
    }
    
    init(playgroundValue: PlaygroundValue) throws {
        guard case let .dictionary(dict) = playgroundValue else {
            throw MappingError(key: "top")
        }
        guard let startLocValue = dict["start"] else {
            throw MappingError(key: "start")
        }
        let start = try Location(playgroundValue: startLocValue)
        guard case let .integer(directionRaw)? = dict["direction"], let direction = Direction(rawValue: directionRaw) else {
            throw MappingError(key: "direction")
        }
        guard case let .integer(length)? = dict["length"] else {
            throw MappingError(key: "length")
        }
        guard case let .string(name)? = dict["name"] else {
            throw MappingError(key: "name")
        }
        self.init(startLocation: start, direction: direction, length: length, name: name)
    }
    
}

extension Area {
    
    func playgroundValue() -> PlaygroundValue {
        return .dictionary([
            "road": adjacentRoad.playgroundValue(),
            "side": .integer(side.rawValue),
            "depth": .integer(depth),
            "type": .integer(type.rawValue),
        ])
    }
    
    init(playgroundValue: PlaygroundValue) throws {
        guard case let .dictionary(dict) = playgroundValue else {
            throw MappingError(key: "top")
        }
        guard let roadValue = dict["road"] else {
            throw MappingError(key: "road")
        }
        let road = try Road(playgroundValue: roadValue)
        guard case let .integer(sideRaw)? = dict["side"], let side = Side(rawValue: sideRaw) else {
            throw MappingError(key: "side")
        }
        guard case let .integer(depth)? = dict["depth"] else {
            throw MappingError(key: "depth")
        }
        guard case let .integer(typeRaw)? = dict["type"], let type = AreaType(rawValue: typeRaw) else {
            throw MappingError(key: "type")
        }
        self.init(adjacentRoad: road, side: side, depth: depth, type: type)
    }
    
}

extension City {
    
    func playgroundValue() -> PlaygroundValue {
        return .dictionary([
            "side": .integer(side),
            "areas": .array(areas.map({ $0.playgroundValue() })),
            "roads": .array(roads.map({ $0.playgroundValue() })),
        ])
    }
    
    init(playgroundValue: PlaygroundValue) throws {
        guard case let .dictionary(dict) = playgroundValue else {
            throw MappingError(key: "top")
        }
        guard case let .array(roadsValues)? = dict["roads"] else {
            throw MappingError(key: "roads")
        }
        let roads = try roadsValues.map({ try Road(playgroundValue: $0) })
        guard case let .array(areasValues)? = dict["areas"] else {
            throw MappingError(key: "areas")
        }
        let areas = try areasValues.map({ try Area(playgroundValue: $0) })
        guard case let .integer(side)? = dict["side"] else {
            throw MappingError(key: "side")
        }
        self.init(side: side)
        self.areas = areas
        self.roads = roads
    }
    
}

extension City {
    public func encoded() -> PlaygroundValue {
        return self.playgroundValue()
    }
}

extension CityViewController : PlaygroundLiveViewMessageHandler {
    
    public func receive(_ message: PlaygroundValue) {
        do {
            let newCity = try City(playgroundValue: message)
            self.updateCity(newCity)
        } catch {
            print(error)
            return
        }
    }
    
}
