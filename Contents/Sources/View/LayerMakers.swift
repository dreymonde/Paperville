import UIKit

struct LayerMaker {
    
    let step: CGFloat
    
    func roadLayers(road: Road) -> (ground: CALayer, label: CALayer) {
        let roadLayer = CALayer()
        roadLayer.backgroundColor = UIColor.road.cgColor
        let roadRect = rect(for: road)
        roadLayer.frame = roadRect
        roadLayer.isOpaque = true
        
        let labelLayer = CATextLayer()
        labelLayer.contentsScale = UIScreen.main.scale * 4
        labelLayer.font = UIFont.preferredFont(forTextStyle: .headline)
        labelLayer.alignmentMode = kCAAlignmentCenter
        labelLayer.string = road.name
        labelLayer.fontSize = 12
        labelLayer.foregroundColor = UIColor.white.cgColor
        labelLayer.zPosition = 4
        labelLayer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        labelLayer.position = CGPoint.init(x: roadLayer.frame.midX, y: roadLayer.frame.midY)
        labelLayer.bounds = CGRect.init(origin: .zero, size: labelLayer.preferredFrameSize())
        
        let arrowLayer = CAShapeLayer()
        let path = CGPath.arrow()
        arrowLayer.path = path
        arrowLayer.bounds = path.boundingBox
        
        print(arrowLayer.bounds)
        arrowLayer.fillColor = UIColor.white.cgColor
        arrowLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        arrowLayer.position.x = labelLayer.bounds.midX
        arrowLayer.position.y -= 2
        
        labelLayer.bounds = labelLayer.bounds.union(arrowLayer.frame)
        labelLayer.addSublayer(arrowLayer)
        
        let angle: CGFloat
        switch road.direction {
        case .right:
            angle = 0
        case .up:
            angle = 0 - CGFloat.pi / 2
        case .down:
            angle = 0 + CGFloat.pi / 2
        case .left:
            angle = CGFloat.pi
        }
        if road.direction == .left {
            arrowLayer.transform = CATransform3DRotate(arrowLayer.transform, angle, 0, 0, 1.0)
        } else {
            labelLayer.transform = CATransform3DRotate(labelLayer.transform, angle, 0, 0, 1.0)
        }
        
        return (roadLayer, labelLayer)
    }
    
    func areaLayers(building: Building) -> (ground: CALayer, hower: CALayer) {
        let areaLayer = CALayer()
        areaLayer.isOpaque = true
        areaLayer.frame = rect(for: building.location)
        areaLayer.backgroundColor = color(for: building.block).cgColor
        
        let areaHowerLayer = CALayer()
        areaHowerLayer.frame = areaLayer.frame
        areaHowerLayer.backgroundColor = UIColor.white.cgColor
        areaHowerLayer.opacity = 0.7
        
        let height = CGFloat(randomNumber(in: 8 ... 15))
        areaHowerLayer.zPosition = height
        
        var rectTransform = CGAffineTransform.init(translationX: 10, y: 10)
        areaHowerLayer.shadowPath = CGPath.init(rect: areaHowerLayer.bounds, transform: &rectTransform)
        areaHowerLayer.shadowRadius = 15.0
        areaHowerLayer.shadowOpacity = 0.6
        areaHowerLayer.rasterize()
        
        return (ground: areaLayer, hower: areaHowerLayer)
    }
    
    func parkLayers(parkLocation: Location) -> (ground: CALayer, trees: [CALayer]) {
        let parkLayer = CALayer()
        parkLayer.isOpaque = true
        parkLayer.frame = rect(for: parkLocation)
        parkLayer.backgroundColor = UIColor.sand.cgColor
        
        let stepInt = Int(step)
        let numberOfTrees = randomNumber(in: 7 ... 16)
        
        var trees: [CALayer] = []
        for _ in 0 ... numberOfTrees {
            let treeHowerLayer = CALayer()
            let treeSide = randomNumber(in: (stepInt / 4) ... (stepInt / 3))
            treeHowerLayer.bounds = CGRect(x: 0, y: 0, width: CGFloat(treeSide), height: CGFloat(treeSide))
            let treeColor = TreeColor(rawValue: randomNumber(in: 1...3))!
            treeHowerLayer.backgroundColor = treeColor.color.cgColor
            let opacityTen = randomNumber(in: 5 ... 10)
            treeHowerLayer.opacity = Float(opacityTen) / 10
            
            let dx = randomNumber(in: -stepInt / 2 ... stepInt / 2)
            let dy = randomNumber(in: -stepInt / 2 ... stepInt / 2)
            treeHowerLayer.position = CGPoint(x: parkLayer.position.x + CGFloat(dx), y: parkLayer.position.y + CGFloat(dy))
            
            let height = randomNumber(in: 5 ... 14)
            treeHowerLayer.zPosition = CGFloat(height)
            
            var shadowRectTransform = CGAffineTransform.init(translationX: 3, y: 3)
            treeHowerLayer.shadowPath = CGPath.init(rect: treeHowerLayer.bounds, transform: &shadowRectTransform)
            treeHowerLayer.shadowRadius = 7.0
            treeHowerLayer.shadowOpacity = 0
            
            trees.append(treeHowerLayer)
        }
        return (ground: parkLayer, trees: trees)
    }
    
    func rect(for road: Road) -> CGRect {
        let startRect = rect(for: road.startLocation)
        let endRect = rect(for: road.endLocation)
        let allXs = [startRect.minX, startRect.maxX, endRect.minX, endRect.maxX]
        let allYs = [startRect.minY, startRect.maxY, endRect.minY, endRect.maxY]
        let origin = CGPoint(x: allXs.min()!, y: allYs.min()!)
        let endPoint = CGPoint(x: allXs.max()!, y: allYs.max()!)
        return CGRect.init(origin: origin, size: CGSize.init(width: endPoint.x - origin.x, height: endPoint.y - origin.y))
    }
    
    func rect(for location: Location) -> CGRect {
        let originX = step * CGFloat(location.x)
        let originY = step * CGFloat(location.y)
        let offset = 2 as CGFloat
        return CGRect(x: originX + offset, y: originY + offset, width: step - offset / 2, height: step - offset / 2)
    }
    
}

func randomNumber<T : SignedInteger>(in range: ClosedRange<T>) -> T {
    let length = Int64(range.upperBound - range.lowerBound + 1)
    let value = Int64(arc4random()) % length + Int64(range.lowerBound)
    return T(value)
}

extension CALayer {
    
    func rasterize() {
        self.shouldRasterize = true
        self.rasterizationScale = 3.0
    }
    
}

extension CGPath {
    
    // courtesy of Rob Mayoff
    static func arrow() -> CGPath {
        
        let start = CGPoint.zero
        let end = CGPoint(x: 14, y: 0)
        let tailWidth: CGFloat = 2
        let headWidth: CGFloat = 6
        let headLength: CGFloat = 6
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength
        
        let points: [CGPoint] = [
            CGPoint(x: 0, y: tailWidth / 2),
            CGPoint(x: tailLength, y: tailWidth / 2),
            CGPoint(x: tailLength, y: headWidth / 2),
            CGPoint(x: length, y: 0),
            CGPoint(x: tailLength, y: -headWidth / 2),
            CGPoint(x: tailLength, y: -tailWidth / 2),
            CGPoint(x: 0, y: -tailWidth / 2)
        ]
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
        
        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()
        
        return path
    }
    
}
