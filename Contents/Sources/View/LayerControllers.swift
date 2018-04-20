import UIKit

extension CATextLayer {
    fileprivate func setStringAndUpdateFrame(string: String?) {
        self.string = string
        bounds = CGRect(origin: .zero, size: preferredFrameSize())
    }
}

final class StatsLayerController {
    
    let mainLayer = CALayer()
    private var stringsLayers: [CATextLayer] = []
    private let create: (Int) -> CATextLayer
    
    convenience init(size: Int) {
        self.init(size: size) { (index) -> CATextLayer in
            let newLayer = CATextLayer()
            newLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
            newLayer.position = CGPoint(x: 10, y: 15 + CGFloat(index) * 20)
            newLayer.contentsScale = UIScreen.main.scale
            newLayer.font = UIFont.boldSystemFont(ofSize: 16)
            newLayer.alignmentMode = kCAAlignmentLeft
            newLayer.fontSize = 16
            newLayer.foregroundColor = UIColor.white.cgColor
            return newLayer
        }
    }
    
    init(size: Int, createLayer: @escaping (Int) -> CATextLayer) {
        self.create = createLayer
        createStringLayers(count: size)
    }
    
    static func unsized(createLayer: @escaping (Int) -> CATextLayer) -> StatsLayerController {
        return StatsLayerController(size: 0, createLayer: createLayer)
    }
    
    func setString(_ string: String?, at index: Int) {
        stringsLayers[index].setStringAndUpdateFrame(string: string)
    }
    
    func setColor(_ color: UIColor?, at index: Int) {
        stringsLayers[index].foregroundColor = color?.cgColor
    }
    
    private func createStringLayers(count: Int) {
        stringsLayers.forEach({ $0.removeFromSuperlayer() })
        stringsLayers = []
        if count == 0 {
            return
        }
        for index in 0 ..< count {
            let newLayer = create(index)
            stringsLayers.append(newLayer)
            mainLayer.addSublayer(newLayer)
        }
    }
    
    func setStrings(_ strings: [(String, UIColor)]) {
        createStringLayers(count: strings.count)
        for ((string, color), index) in zip(strings, strings.indices) {
            setString(string, at: index)
            setColor(color, at: index)
        }
    }
    
}

final class BuildingStatLayerController {
    
    let mainLayer = CALayer()
    private let titleLayer = CATextLayer()
    private let employmentStatusLayer = CATextLayer()
    private let comfortScoreLayer = CATextLayer()
    private let comfortScoreTitleLayer = CATextLayer()
    
    private let hintsController = StatsLayerController.unsized { (index) -> CATextLayer in
        let newLayer = CATextLayer()
        newLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        newLayer.position = CGPoint(x: 0, y: CGFloat(index) * 12)
        newLayer.contentsScale = UIScreen.main.scale * 2
        newLayer.font = UIFont.boldSystemFont(ofSize: 8)
        newLayer.alignmentMode = kCAAlignmentLeft
        newLayer.fontSize = 8
        newLayer.foregroundColor = UIColor.black.cgColor
        return newLayer
    }
    
    func setTitle(_ title: String?) {
        titleLayer.setStringAndUpdateFrame(string: title)
    }
    
    func setEmploymentStatus(_ newValue: String?) {
        employmentStatusLayer.setStringAndUpdateFrame(string: newValue)
    }
    
    func setComfortScore(_ newValue: String?) {
        comfortScoreLayer.setStringAndUpdateFrame(string: newValue)
        comfortScoreTitleLayer.position.x = comfortScoreLayer.frame.minX + 2
    }
    
    func setComfortScoreTitle(_ newValue: String?) {
        comfortScoreTitleLayer.setStringAndUpdateFrame(string: newValue)
    }
    
    func setTitleColor(_ color: UIColor?) {
        titleLayer.foregroundColor = color?.cgColor
    }
    
    func setEmploymentStatusColor(_ color: UIColor?) {
        employmentStatusLayer.foregroundColor = color?.cgColor
    }
    
    func setComfortScoreColor(_ color: UIColor?) {
        comfortScoreLayer.foregroundColor = color?.cgColor
    }
    
    func setHints(_ hints: [(String, UIColor)]) {
        hintsController.setStrings(hints)
    }
    
    init() {
        mainLayer.addSublayer(titleLayer)
        mainLayer.addSublayer(employmentStatusLayer)
        mainLayer.addSublayer(comfortScoreTitleLayer)
        mainLayer.addSublayer(comfortScoreLayer)
        mainLayer.addSublayer(hintsController.mainLayer)
        mainLayer.backgroundColor = UIColor.red.cgColor
        
        titleLayer.contentsScale = UIScreen.main.scale * 2
        titleLayer.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLayer.alignmentMode = kCAAlignmentCenter
        titleLayer.fontSize = 14
        titleLayer.foregroundColor = UIColor.black.cgColor
        
        employmentStatusLayer.contentsScale = UIScreen.main.scale * 2
        employmentStatusLayer.font = UIFont.preferredFont(forTextStyle: .callout)
        employmentStatusLayer.alignmentMode = kCAAlignmentCenter
        employmentStatusLayer.fontSize = 10
        employmentStatusLayer.foregroundColor = UIColor.darkGray.cgColor
        
        comfortScoreTitleLayer.contentsScale = UIScreen.main.scale * 2
        comfortScoreTitleLayer.font = UIFont.preferredFont(forTextStyle: .callout)
        comfortScoreTitleLayer.alignmentMode = kCAAlignmentCenter
        comfortScoreTitleLayer.fontSize = 10
        comfortScoreTitleLayer.foregroundColor = UIColor.darkGray.cgColor
        
        comfortScoreLayer.contentsScale = UIScreen.main.scale * 2
        comfortScoreLayer.font = UIFont.preferredFont(forTextStyle: .title1)
        comfortScoreLayer.alignmentMode = kCAAlignmentCenter
        comfortScoreLayer.fontSize = 42
        comfortScoreLayer.foregroundColor = UIColor.darkGray.cgColor
        
        titleLayer.position = CGPoint.init(x: 117, y: 20)
        
        employmentStatusLayer.position = CGPoint(x: 117, y: 35)
        
        comfortScoreLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        comfortScoreLayer.position = CGPoint(x: 14, y: 85)
        
        comfortScoreTitleLayer.position = CGPoint(x: 70, y: 55)
        comfortScoreTitleLayer.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        hintsController.mainLayer.position = CGPoint(x: 130, y: 55)
    }
    
}

extension Float {
    
    func formatted(afterDot: Int) -> String {
        return String.init(format: "%.\(afterDot)f", self)
    }
    
}

