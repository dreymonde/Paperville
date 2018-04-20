
public enum StreetName {
    
    case marketSt
    case firstSt
    case secondSt
    case thirdSt
    case fourthSt
    case parkSt
    case pineSt
    case cedarSt
    case sunsetSt
    case swiftSt
    case objectiveSt
    case worldwideSt
    case elmSt
    case oakSt
    case spearSt
    case newSt
    case eidhofSt
    case sadunSt
    case khanlouSt
    case squiresSt
    case merowingSt
    case potterSt
    case verwerSt
    case hyperSt
    case cocoaSt
    case foundationSt
    case appleSt
    case quartzSt
    case custom(String)
    
    public var rawValue: String {
        switch self {
        case .custom(let string):
            return string
        case .marketSt:     return "Market St"
        case .firstSt:      return "1st St"
        case .secondSt:     return "2nd St"
        case .thirdSt:      return "3rd St"
        case .fourthSt:     return "4th St"
        case .parkSt:       return "Park St"
        case .pineSt:       return "Pine St"
        case .cedarSt:      return "Cedar St"
        case .sunsetSt:     return "Sunset St"
        case .swiftSt:      return "Swift St"
        case .objectiveSt:  return "Objective St"
        case .worldwideSt:  return "Worldwide St"
        case .elmSt:        return "Elm St"
        case .oakSt:        return "Oak St"
        case .spearSt:      return "Spear St"
        case .newSt:        return "New St"
        case .eidhofSt:     return "Eidhof St"
        case .sadunSt:      return "Sadun St"
        case .khanlouSt:    return "Khanlou St"
        case .squiresSt:    return "Squires St"
        case .merowingSt:   return "Merowing St"
        case .potterSt:     return "Potter St"
        case .verwerSt:     return "Verwer St"
        case .hyperSt:      return "Hyper St"
        case .cocoaSt:      return "Cocoa St"
        case .foundationSt: return "Foundation St"
        case .appleSt:      return "Apple St"
        case .quartzSt:     return "Quartz St"
        }
    }
    
}
