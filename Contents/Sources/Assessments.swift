
public enum Assessment {
    case pass(message: String?)
    case fail(hints: [String], solution: String?)
}

public enum Check {
    
    public static func first() -> Assessment {
        if City.shared.plan.residential.isEmpty == false {
            return .pass(message: "Great! This is your first housing. If you're curious, you can try to change the area from `.housing` to something else and see how it rebuilds. Then head to the [next page](@next)!")
        } else {
            return .fail(hints: ["Make sure you're building `.housing`"], solution: nil)
        }
    }
    
    public static func second() -> Assessment {
        var hints: [String] = []
        if City.shared.roads.contains(where: { $0.name == StreetName.marketSt.rawValue }) == false {
            hints.append("Make sure that the street name is `.marketSt`")
        }
        if City.shared.plan.residential.isEmpty == true {
            hints.append("There are no houses in your city. Use `.buildLeft(.housing)` or `.buildRight(.housing)` on roads.")
        }
        if City.shared.plan.commercial.isEmpty == true {
            hints.append("There are no shops in your city. Use `.buildLeft(.commerce)` or `.buildRight(.commerce)` on roads.")
        }
        if City.shared.plan.parks.isEmpty == true {
            hints.append("There are no parks in your city. Use `.buildLeft(.park)` or `.buildRight(.park)` on roads.")
        }
        if hints.isEmpty {
            return .pass(message: "Awesome! On the [next page](@next) we're going to explore the economics of the city.")
        } else {
            let solution = """
````
let marketSt = mainStreet.center.roadRight(length: 5, name: .marketSt)
marketSt.buildLeft(.commerce)
marketSt.buildRight(.housing)
mainStreet.buildLeft(.park)
````
"""
            return Assessment.fail(hints: hints, solution: solution)
        }
    }
    
    public static func third() -> Assessment {
        let census = Census(plan: City.shared.plan)
        if abs(census.residentialsTotal - census.workPlacesTotal) < 5 {
            return .pass(message: "See that brightness? The city is alive again! Now, when you know how the economics in **Paperville** works, it's time for the [final page](@next)!")
        } else {
            var hints: [String] = []
            if census.residentialsTotal > census.workPlacesTotal {
                hints.append("The city still doesn't have enough jobs. Use `.buildRight(.industry)` or `.buildLeft(.industry)` to build factories")
            } else {
                hints.append("Whoops, seems like too much! Remove some of the factories or build additional housing.")
            }
            let solution = "`industrialSt.buildRight(.industry)`"
            return .fail(hints: hints, solution: solution)
        }
    }
    
    public static func fourth() -> Assessment {
        let distribution = Distribution(plan: City.shared.plan)
        let census = distribution.census
        var hints: [String] = []
        if census.economicBalance < 0.9 {
            hints.append("You haven't achieved a desired economic balance. Tap on any shop or factory to reveal a city economic balance. Strive for value **above 0.9**.")
        }
        if distribution.averageComfortScore() < 90 {
            hints.append("Average comfort score is too low. Explore different neighborhoods and find a way to improve them by placing parks, bringing in neighbors and new businesses, and moving factories (they pollute the air). Aim for the score **above 90%**.")
        }
        if census.industrial.count < 5 {
            hints.append("Not enough factories! Build more with `.buildRight(.industry)`. You need to have **at least 5** of them.")
        }
        if census.residentialsTotal < 30 {
            hints.append("Not enough population! Zone more areas with `.buildRight(.housing)`. You need to have **at least 30** houses.")
        }
        if hints.isEmpty {
            return .pass(message: "Congratulations! You've mastered the urban planning of **Paperville**!. Hope you enjoyed it!")
        } else {
            hints.append("You can reveal detailed **comfort score** information for each house by **tapping** on them.")
            return .fail(hints: hints, solution: nil)
        }
    }
    
}
