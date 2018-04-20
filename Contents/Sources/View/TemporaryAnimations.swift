import UIKit

struct TemporatyState {
    let run: () -> ()
    let rollback: () -> ()
    
    mutating func add(_ other: TemporatyState) {
        self = adding(other)
    }
    
    func adding(_ other: TemporatyState) -> TemporatyState {
        return TemporatyState(run: { self.run(); other.run() },
                              rollback: { self.rollback(); other.rollback() })
    }
}

struct BuildingPeekAnimator {
    
    let buildingStatsLayerController = BuildingStatLayerController()
    
    func peek(areaLayers layers: (ground: CALayer, hower: CALayer),
              building: Building,
              distribution: Distribution,
              buildingsLayers: [Building : (ground: CALayer, hower: CALayer)],
              parksLayers: [Location : (ground: CALayer, trees: [CALayer])]) -> TemporatyState {
        
        let originalHeight = layers.hower.zPosition
        
        let move = {
            let ground = layers.ground
            ground.zPosition = 1
            ground.transform = CATransform3DScale(ground.transform, 1.5, 1.5, 1)
            layers.hower.shouldRasterize = false
            let howerOriginalTransform = layers.hower.transform
            let scaled = CATransform3DScale(howerOriginalTransform, 6, 3, 1)
            let moved = CATransform3DTranslate(scaled, 0, 30, 0)
            layers.hower.transform = moved
            layers.hower.zPosition = 50
            layers.hower.opacity = 0.85
            let status = employmentStatus(for: building.block,
                                          fullness: distribution.fullnessMap[building.location]!)
            let scoreInfo = score(for: building, in: distribution)
            CATransaction.withoutAnimation {
                let stats = self.buildingStatsLayerController
                stats.setTitle(title(for: building.block))
                stats.setTitleColor(color(for: building.block))
                stats.setEmploymentStatus(status.description)
                stats.setEmploymentStatusColor(status.summary.color)
                stats.mainLayer.transform = CATransform3DInvert(scaled)
                stats.setComfortScore(scoreInfo.score)
                stats.setComfortScoreTitle(scoreInfo.title)
                stats.setComfortScoreColor(scoreInfo.scoreColor)
                stats.setHints(scoreInfo.hints)
            }
            layers.hower.addSublayer(self.buildingStatsLayerController.mainLayer)
        }
        
        let rollback = {
            layers.ground.zPosition = 0
            layers.ground.transform = CATransform3DIdentity
            layers.hower.transform = CATransform3DIdentity
            layers.hower.shouldRasterize = true
            layers.hower.opacity = 0.7
            layers.hower.zPosition = originalHeight
            self.buildingStatsLayerController.mainLayer.removeFromSuperlayer()
        }
        
        var animation = TemporatyState(run: move, rollback: rollback)
        
        if building.block != .residential {
            return animation
        }
        
        guard let analysis = distribution.analysisMap[building.location] else {
            return animation
        }
        
        let nearBuildings = Set(analysis.walkableLocations.keys)
        for (otherBuilding, layers) in buildingsLayers {
            guard !nearBuildings.contains(otherBuilding.location) else {
                continue
            }
            guard building != otherBuilding else {
                continue
            }
            animation.add(desaturate(areaLayers: layers))
        }
        
        for (parkLocation, parkLayers) in parksLayers {
            guard !nearBuildings.contains(parkLocation) else {
                continue
            }
            let layers = [parkLayers.ground] + parkLayers.trees
            animation.add(desaturate(parkLayers: layers))
        }
        
        return animation
        
    }
    
}

func desaturate(areaLayers layers: (ground: CALayer, hower: CALayer)) -> TemporatyState {
    let currentColor = layers.ground.backgroundColor
    let move = {
        layers.hower.zPosition /= 10
        layers.ground.backgroundColor = UIColor.disabled.cgColor
        layers.hower.opacity /= 2
    }
    let rollback = {
        layers.hower.zPosition *= 10
        layers.ground.backgroundColor = currentColor
        layers.hower.opacity *= 2
    }
    let animation = TemporatyState(run: move, rollback: rollback)
    return animation
}

func desaturate(parkLayers layers: [CALayer]) -> TemporatyState {
    let currentColors = layers.map({ $0.backgroundColor })
    let move = {
        for layer in layers {
            layer.zPosition /= 10
            layer.backgroundColor = layer.backgroundColor?.grayscale()
        }
    }
    let rollback = {
        for (layer, color) in zip(layers, currentColors) {
            layer.zPosition *= 10
            layer.backgroundColor = color
        }
    }
    let animation = TemporatyState(run: move, rollback: rollback)
    return animation
}

extension CGColor {
    
    func grayscale() -> CGColor? {
        return self.converted(to: CGColorSpaceCreateDeviceGray(), intent: .defaultIntent, options: nil)
    }
    
}
