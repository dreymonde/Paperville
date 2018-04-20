import UIKit

public class CityViewController: UIViewController {
    
    let cityLayer = CALayer()
    
    var buildingsLayers: [Building : (ground: CALayer, hower: CALayer)] = [:]
    var roadsLayers: [Road: (ground: CALayer, label: CALayer)] = [:]
    var parksLayers: [Location : (ground: CALayer, trees: [CALayer])] = [:]
    
    let step: CGFloat = 40
    let maker: LayerMaker
    
    public var city: City = .shared {
        didSet {
            distribution = Distribution(plan: city.plan)
        }
    }
    private var distribution: Distribution {
        didSet {
            updateStatsLayer()
        }
    }
    
    let isEconomicsEnabled: Bool
    
    let statsLayerController = StatsLayerController(size: 3)
    let showcaser = BuildingPeekAnimator()
    let animationQueue = AnimationQueue()
    
    public init(isEconomicsEnabled: Bool = true) {
        self.distribution = Distribution(plan: city.plan)
        self.isEconomicsEnabled = isEconomicsEnabled
        self.maker = LayerMaker(step: step)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let pan = UIPanGestureRecognizer()
    let pinch = UIPinchGestureRecognizer()
    let tap = UITapGestureRecognizer()
    
    public override func loadView() {
        view = UIView()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .unbordered
        
        let side = step * CGFloat(city.side)
        cityLayer.bounds = CGRect(x: 0, y: 0, width: side, height: side)
        cityLayer.backgroundColor = UIColor.background.cgColor
        
        setupCityLayer()
        initialDrawLayers()
        self.view.layer.addSublayer(cityLayer)
        
        if isEconomicsEnabled {
            let statsLayer = statsLayerController.mainLayer
            self.view.layer.addSublayer(statsLayer)
            statsLayer.frame = CGRect(x: 0, y: 80, width: 190, height: 10 + CGFloat(3) * 20)
            statsLayer.backgroundColor = UIColor.black.cgColor
            statsLayer.opacity = 0.7
        }
        updateStatsLayer()
        
        pan.addTarget(self, action: #selector(didPan(recognizer:)))
        view.addGestureRecognizer(pan)
        
        pinch.addTarget(self, action: #selector(didPinch(recognizer:)))
        view.addGestureRecognizer(pinch)
        
        tap.addTarget(self, action: #selector(didTap(recognizer:)))
        view.addGestureRecognizer(tap)
    }
    
    public override func viewWillLayoutSubviews() {
        CATransaction.withoutAnimation {
            cityLayer.position = view.center
        }
    }
    
    var currentlyShowingBuilding: Building?
    var temporaryState: TemporatyState?
    
    @objc func didTap(recognizer: UITapGestureRecognizer) {
        guard isEconomicsEnabled else {
            return
        }
        let point = cityLayer.convert(recognizer.location(in: view), from: view.layer)
        let building = self.building(for: point)
        temporaryState?.rollback()
        temporaryState = nil
        if currentlyShowingBuilding == building {
            currentlyShowingBuilding = nil
            return
        }
        currentlyShowingBuilding = building
        if let layers = buildingsLayers[building] {
            let animation = showcaser.peek(areaLayers: layers,
                                           building: building,
                                           distribution: self.distribution,
                                           buildingsLayers: self.buildingsLayers,
                                           parksLayers: self.parksLayers)
            temporaryState = animation
            animation.run()
        }
    }
    
    @objc func didPinch(recognizer: UIPinchGestureRecognizer) {
        defer {
            recognizer.scale = 1.0
        }
        if recognizer.scale != 1.0 {
            let scale = recognizer.scale
            CATransaction.withoutAnimation {
                cityLayer.transform = CATransform3DScale(cityLayer.transform, scale, scale, 1)
                cityLayer.sublayerTransform.m34 *= scale
            }
        }
    }
    
    @objc func didPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let relativeTranslation = CGPoint(x: translation.x / cityLayer.frame.width, y: translation.y / cityLayer.frame.height)
        CATransaction.withoutAnimation {
            cityLayer.anchorPoint.x -= relativeTranslation.x
            cityLayer.anchorPoint.y -= relativeTranslation.y
        }
        recognizer.setTranslation(.zero, in: view)
    }
    
    func setupCityLayer() {
        let originalFrame = cityLayer.frame
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 200
        cityLayer.sublayerTransform = transform
        cityLayer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        cityLayer.frame = originalFrame
    }
    
    func setOpacity(building: Building, layer: CALayer) {
        guard isEconomicsEnabled else {
            return
        }
        switch building.block {
        case .residential:
            let analysis = distribution.analysisMap[building.location]!
            layer.opacity = analysis.comfortScoreFloat
        default:
            layer.opacity = distribution.fullnessMap[building.location]!.floatingValue
        }
    }
    
    func initialDrawLayers() {
        cityLayer.sublayers = []
        
        let plan = city.plan
        
        for parkLocation in plan.parks {
            let layers = maker.parkLayers(parkLocation: parkLocation)
            parksLayers[parkLocation] = layers
            cityLayer.addSublayer(layers.ground)
            for tree in layers.trees {
                cityLayer.addSublayer(tree)
            }
        }
        
        for areaLocation in plan.buildings {
            let block = plan.blocks[areaLocation.y][areaLocation.x]
            let building = Building(location: areaLocation, block: block)
            let layers = maker.areaLayers(building: building)
            setOpacity(building: building, layer: layers.ground)
            buildingsLayers[building] = layers
            cityLayer.addSublayer(layers.ground)
            cityLayer.addSublayer(layers.hower)
        }
        
        for road in city.roads {
            let layers = maker.roadLayers(road: road)
            roadsLayers[road] = layers
            cityLayer.addSublayer(layers.ground)
            cityLayer.addSublayer(layers.label)
        }
    }
    
    func location(for point: CGPoint) -> Location {
        let x = Int(point.x / step)
        let y = Int(point.y / step)
        return Location(x: x, y: y)
    }
    
    func building(for point: CGPoint) -> Building {
        let loc = location(for: point)
        let block = distribution.census.plan[loc]
        return Building(location: loc, block: block)
    }
    
    public func updateCity(_ newCity: City) {
        guard newCity != city else {
            return
        }
        self.city = newCity
        let plan = newCity.plan
        let parks = updateParks(newParkLocations: plan.parks)
        let buildings = updateBuildings(newBuildings: plan.buildings.map({ Building.init(location: $0, block: plan[$0]) }))
        let roads = updateRoads(newRoads: newCity.roads)
        parks.removeOld()
        buildings.removeOld()
        roads.removeOld()
        roads.buildNew()
        buildings.buildNew()
        parks.buildNew()
        for (building, layers) in buildingsLayers {
            animationQueue.enqueue(delaying: 0.02) {
                self.setOpacity(building: building, layer: layers.ground)
            }
        }
    }
    
    func updateStatsLayer() {
        let pop = "Pop.: \(distribution.census.residentialsTotal)"
        let jobs = "Jobs: \(distribution.census.workPlacesTotal)"
        let avgComfort = "Avg. comfort: \(distribution.averageComfortScore())%"
        statsLayerController.setString(pop, at: 0)
        statsLayerController.setString(jobs, at: 1)
        statsLayerController.setString(avgComfort, at: 2)
    }
    
    func updateRoads(newRoads: [Road]) -> Update {
        return update(new: newRoads, current: Array(roadsLayers.keys), remove: { (roadToRemove) in
            guard let layers = self.roadsLayers.removeValue(forKey: roadToRemove) else {
                return
            }
            self.animationQueue.enqueue {
                layers.ground.removeFromSuperlayer()
                layers.label.removeFromSuperlayer()
            }
        }, build: { (roadToBuild) in
            let layers = self.maker.roadLayers(road: roadToBuild)
            self.roadsLayers[roadToBuild] = layers
            self.animationQueue.enqueue {
                self.cityLayer.addSublayer(layers.ground)
                self.cityLayer.addSublayer(layers.label)
            }
        })
    }
    
    func updateParks(newParkLocations: [Location]) -> Update {
        return update(new: newParkLocations, current: Array(parksLayers.keys), remove: { (parkToRemove) in
            guard let layers = self.parksLayers.removeValue(forKey: parkToRemove) else {
                return
            }
            self.animationQueue.enqueue {
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    layers.ground.removeFromSuperlayer()
                })
                layers.ground.bounds = .zero
                CATransaction.commit()
            }
            for tree in layers.trees {
                self.animationQueue.enqueue(delaying: 0.01, {
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({
                        tree.removeFromSuperlayer()
                    })
                    tree.zPosition = 0.01
                    tree.opacity = 0
                    CATransaction.commit()
                })
            }
        }, build: { (parkToBuild) in
            let layers = self.maker.parkLayers(parkLocation: parkToBuild)
            self.parksLayers[parkToBuild] = layers
            self.cityLayer.addSublayer(layers.ground)
            for tree in layers.trees {
                self.cityLayer.addSublayer(tree)
            }
            let desiredBounds = layers.ground.bounds
            let desiredHeightsAndOpacities = layers.trees.map({ ($0.zPosition, $0.opacity) })
            
            layers.ground.bounds = .zero
            layers.trees.forEach({ $0.zPosition = 0.01; $0.opacity = 0 })
            
            CATransaction.flush()
            self.animationQueue.enqueue {
                CATransaction.begin()
                layers.ground.bounds = desiredBounds
                CATransaction.commit()
            }
            for (tree, (height, opacity)) in zip(layers.trees, desiredHeightsAndOpacities) {
                self.animationQueue.enqueue(delaying: 0.01, {
                    CATransaction.begin()
                    tree.zPosition = height
                    tree.opacity = opacity
                    CATransaction.commit()
                })
            }
        })
    }
    
    func updateBuildings(newBuildings: [Building]) -> Update {
        return update(new: newBuildings, current: Array(buildingsLayers.keys), remove: { (buildingToRemove) in
            guard let layers = self.buildingsLayers.removeValue(forKey: buildingToRemove) else {
                return
            }
            self.animationQueue.enqueue {
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    layers.ground.removeFromSuperlayer()
                    layers.hower.removeFromSuperlayer()
                })
                layers.ground.bounds = .zero
                layers.hower.opacity = 0
                layers.hower.zPosition = 0.03
                CATransaction.commit()
            }
            
        }, build: { (buildingToBuild) in
            
            let layers = self.maker.areaLayers(building: buildingToBuild)
            self.setOpacity(building: buildingToBuild, layer: layers.ground)
            self.buildingsLayers[buildingToBuild] = layers
            self.cityLayer.addSublayer(layers.ground)
            self.cityLayer.addSublayer(layers.hower)
            
            let desiredBounds = layers.ground.bounds
            let desiredOpacity = layers.hower.opacity
            let desiredHeight = layers.hower.zPosition
            layers.ground.bounds = .zero
            layers.hower.opacity = 0
            layers.hower.zPosition = 0.03
            
            CATransaction.flush()
            
            self.animationQueue.enqueue {
                CATransaction.begin()
                layers.ground.bounds = desiredBounds
                layers.hower.opacity = desiredOpacity
                layers.hower.zPosition = desiredHeight
                CATransaction.commit()
            }
        })
    }
    
}

final class AnimationQueue {
    
    init(minInterval: TimeInterval = 0.1) {
        self.minInterval = minInterval
    }
    
    private var lastBuildInTime: Date = Date()
    private var minInterval: TimeInterval
    
    private func beginTimeForNextAnimation(delay: TimeInterval) -> Date {
        return max(Date(), lastBuildInTime + delay)
    }
    
    func enqueue(delaying delay: TimeInterval, _ animation: @escaping () -> ()) {
        let nextAnimationTime = beginTimeForNextAnimation(delay: delay)
        lastBuildInTime = nextAnimationTime
        let timer = Timer(fire: nextAnimationTime, interval: 0, repeats: false, block: { (_) in
            animation()
        })
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    func enqueue(_ animation: @escaping () -> ()) {
        enqueue(delaying: minInterval, animation)
    }
    
}

struct Update {
    let removeOld: () -> ()
    let buildNew: () -> ()
}

func update<T : Hashable>(new: [T], current: [T], remove: @escaping (T) -> (), build: @escaping (T) -> ()) -> Update {
    var toRemove = Set(current)
    var toBuild: [T] = []
    for item in new {
        if current.contains(item) {
            toRemove.remove(item)
        } else {
            toBuild.append(item)
        }
    }
    var removeAction = { }
    var buildAction = { }
    for removing in toRemove {
        let current = removeAction
        removeAction = { current(); remove(removing) }
    }
    for building in toBuild {
        let current = buildAction
        buildAction = { current(); build(building) }
    }
    return Update(removeOld: removeAction, buildNew: buildAction)
}

extension CATransaction {
    static func withoutAnimation(perform: () -> ()) {
        begin()
        setDisableActions(true)
        perform()
        commit()
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

