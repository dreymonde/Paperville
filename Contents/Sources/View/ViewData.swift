import UIKit

extension UIColor {
    
    static let road = UIColor(red:0.87, green:0.90, blue:0.91, alpha:1.0)
    static let unbordered = UIColor(red:0.97, green:0.95, blue:0.89, alpha:1.0)
    static let homes = UIColor(red:0.00, green:0.72, blue:0.58, alpha:1.0)
    static let commerce = UIColor(red:0.45, green:0.73, blue:1.00, alpha:1.0)
    static let industry = UIColor(red:0.99, green:0.80, blue:0.43, alpha:1.0)
    static let disabled = UIColor(red:0.70, green:0.75, blue:0.76, alpha:0.7)
    static let sand = UIColor(red:0.80, green:0.68, blue:0.38, alpha:0.3)
    static let grass = UIColor(red:0.33, green:0.94, blue:0.77, alpha:1.0)
    static let darkTree = UIColor(red:0.13, green:0.55, blue:0.45, alpha:1.0)
    static let tree = UIColor(red:0.00, green:0.72, blue:0.58, alpha:1.0)
    static let background = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
    static let notGood = UIColor(red:0.71, green:0.20, blue:0.44, alpha:1.0)
    static let fine = UIColor(red:0.00, green:0.38, blue:0.40, alpha:1.0)
    
}

enum TreeColor : Int {
    
    case first = 1, second, third
    
    var color: UIColor {
        switch self {
        case .first:
            return .grass
        case .second:
            return .tree
        case .third:
            return .darkTree
        }
    }
    
}

func color(for block: City.Block) -> UIColor {
    switch block {
    case .residential:
        return .homes
    case .commercial:
        return .commerce
    case .industrial:
        return .industry
    case .park:
        return .yellow
    default:
        return .clear
    }
}

func title(for block: City.Block) -> String {
    switch block {
    case .residential:
        return "residential building"
    case .commercial:
        return "commercial building"
    case .industrial:
        return "industrial building"
    default:
        return "other"
    }
}

struct EmploymentStatus {
    let description: String
    let summary: Summary
    
    enum Summary {
        case good
        case bad
        
        var color: UIColor {
            switch self {
            case .good:
                return .fine
            case .bad:
                return .notGood
            }
        }
    }
}

func employmentStatus(for block: City.Block, fullness: Fullness) -> EmploymentStatus {
    switch block {
    case .residential:
        if fullness.n == fullness.outOf {
            return EmploymentStatus(description: "employed", summary: .good)
        } else {
            return EmploymentStatus(description: "unemployed", summary: .bad)
        }
    case .industrial, .commercial:
        let desc = "jobs taken: \(fullness.n) / \(fullness.outOf)"
        if fullness.n == fullness.outOf {
            return EmploymentStatus(description: desc, summary: .good)
        } else {
            return EmploymentStatus(description: desc, summary: .bad)
        }
    default:
        return EmploymentStatus(description: "other", summary: .good)
    }
}

struct ScoreInfo {
    let title: String?
    let score: String?
    let scoreColor: UIColor?
    var hints: [(String, UIColor)]
}

func score(for building: Building, in distribution: Distribution) -> ScoreInfo {
    switch building.block {
    case .residential:
        let analyzer = distribution.analysisMap[building.location]!
        let score = analyzer.comfortScore
        let comfortScore = "\(score)%"
        let color: UIColor = score > 60 ? .darkGray : .notGood
        let neighborsHint: (String, UIColor) = {
            let value = analyzer.neighborsModifier.formatted(afterDot: 2)
            let string = "x\(value): neighbors \(analyzer.neighbors)/6"
            let color: UIColor = analyzer.neighborsModifier > 0.8 ? .fine : .notGood
            return (string, color)
        }()
        let commercialHint: (String, UIColor) = {
            let value = analyzer.commercialModifier.formatted(afterDot: 2)
            let string = "x\(value): shops \(analyzer.commercialSpaces)/6"
            let color: UIColor = analyzer.commercialModifier > 0.8 ? .fine : .notGood
            return (string, color)
        }()
        let factoriesHint: (String, UIColor) = {
            let value = analyzer.industryModifier.formatted(afterDot: 2)
            let string = "x\(value): \(analyzer.factories) factories"
            let color: UIColor = analyzer.industryModifier > 0.85 ? .fine : .notGood
            return (string, color)
        }()
        let parkHint: (String, UIColor) = {
            let value = analyzer.parkModifier.formatted(afterDot: 2)
            let parkString = analyzer.parkPresence ? "park nearby" : "no parks"
            let string = "x\(value): \(parkString)"
            let color: UIColor = analyzer.parkPresence ? .fine : .notGood
            return (string, color)
        }()
        let employmentHint: (String, UIColor) = {
            let value = analyzer.employmentModifier.formatted(afterDot: 2)
            let employmentString = analyzer.fullness.isFull ? "employed" : "unemployed"
            let string = "x\(value): \(employmentString)"
            let color: UIColor = analyzer.fullness.isFull ? .darkGray : .notGood
            return (string, color)
        }()
        return ScoreInfo(title: "comfort score",
                         score: comfortScore,
                         scoreColor: color,
                         hints: [neighborsHint, commercialHint, factoriesHint, parkHint, employmentHint])
    case .commercial, .industrial:
        let score = distribution.census.economicBalance
        let color: UIColor = score > 0.8 ? .darkGray : .notGood
        let formatted = score.formatted(afterDot: 2)
        let factoriesHint = "\(distribution.census.industrial.count) factories (\(distribution.census.industrial.count * 3) jobs)"
        let shopsHint = "\(distribution.census.commercial.count) shops (\(distribution.census.commercial.count) jobs)"
        let jobsHint = "jobs: \(distribution.census.workPlacesTotal)"
        let popHint = "population: \(distribution.census.residentialsTotal)"
        return ScoreInfo(title: "city economic balance",
                         score: formatted,
                         scoreColor: color,
                         hints: [factoriesHint, shopsHint, popHint, jobsHint].map({ ($0, UIColor.lightGray) }))
    default:
        return ScoreInfo(title: nil, score: nil, scoreColor: nil, hints: [])
    }
}
