
extension City {
    public static var shared = City(side: 40)
}

fileprivate func add(_ road: Road) {
    City.shared.roads.append(road)
}

fileprivate func add(_ area: Area) {
    City.shared.areas.append(area)
}

public func mainRoad() -> Road {
    let citySide = City.shared.side
    let length = citySide / 2 - 2
    let startLocation = Location(x: citySide / 2, y: citySide / 2 + length / 2 - 1)
    let road = Road(startLocation: startLocation, direction: .up, length: length, name: "Main Street")
    add(road)
    return road
}

extension Road {
    
    @discardableResult
    public func buildLeft(_ area: AreaType) -> Area {
        let area = self.areaToLeft(area, depth: 1)
        add(area)
        return area
    }
    
    @discardableResult
    public func buildRight(_ area: AreaType) -> Area {
        let area = self.areaToRight(area, depth: 1)
        add(area)
        return area
    }
    
    public func depth(_ depth: Int) -> InDepth {
        precondition(depth > 1, "Area depth should be positive")
        return InDepth(road: self, depth: depth)
    }
    
}

extension Anchor {
    
    @discardableResult
    public func roadLeft(length: Int, name: StreetName) -> Road {
        let road = self.roadToLeft(length: length + 1, name: name.rawValue)
        add(road)
        return road
    }
    
    @discardableResult
    public func roadRight(length: Int, name: StreetName) -> Road {
        let road = self.roadToRight(length: length + 1, name: name.rawValue)
        add(road)
        return road
    }
    
    @discardableResult
    public func road(to otherRoad: Road, name: StreetName) -> Road {
        precondition(otherRoad.direction.alignment == road.direction.alignment)
        return road(toAlignWith: otherRoad.start, name: name)
    }
    
    fileprivate func road(toAlignWith anchor: Anchor, name: StreetName) -> Road {
        func submitted(road: Road) -> Road {
            add(road)
            return road
        }
        switch road.direction.alignment {
        case .vertical:
            let distance = anchor.location.x - location.x
            let direction: Road.Direction = distance > 0 ? .right : .left
            let road = Road(startLocation: location, direction: direction, length: abs(distance) + 1, name: name.rawValue)
            return submitted(road: road)
        case .horizontal:
            let distance = anchor.location.y - location.y
            let direction: Road.Direction = distance > 0 ? .down : .up
            let road = Road(startLocation: location, direction: direction, length: abs(distance) + 1, name: name.rawValue)
            return submitted(road: road)
        }
    }
    
}

extension Road {
    
    public struct InDepth {
        
        let road: Road
        let depth: Int
        
        @discardableResult
        public func buildLeft(_ area: AreaType) -> Area {
            let area = road.areaToLeft(area, depth: depth)
            add(area)
            return area
        }
        
        @discardableResult
        public func buildRight(_ area: AreaType) -> Area {
            let area = road.areaToRight(area, depth: depth)
            add(area)
            return area
        }
        
    }
    
}
