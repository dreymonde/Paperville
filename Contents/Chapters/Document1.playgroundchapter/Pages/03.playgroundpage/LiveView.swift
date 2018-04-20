
import PlaygroundSupport

let page = PlaygroundPage.current

City.shared = City(side: 30)
let mainStreet = mainRoad()

mainStreet.buildLeft(.park)

let firstSt = mainStreet.center
    .roadRight(length: 7, name: .firstSt)
let cocoaSt = firstSt.center
    .roadLeft(length: 6, name: .cocoaSt)
let sunsetSt = firstSt.center
    .roadRight(length: 6, name: .sunsetSt)

cocoaSt.buildLeft(.housing)
firstSt.segment.before(cocoaSt)
    .buildLeft(.park)
firstSt.segment.before(sunsetSt)
    .buildRight(.park)
firstSt.segment.after(cocoaSt)
    .buildLeft(.commerce)
firstSt.segment.after(sunsetSt)
    .buildRight(.commerce)
sunsetSt.buildRight(.housing)

let industrialSt = mainStreet[1]
    .roadLeft(length: 5, name: .custom("Industrial St"))

mainStreet.segment.after(firstSt)
    .buildRight(.housing)
let secondSt = mainStreet.center
    .roadLeft(length: 4, name: .secondSt)
secondSt.buildRight(.housing)
secondSt.firstHalf.buildLeft(.commerce)

let vc = CityViewController(isEconomicsEnabled: true)
page.liveView = vc
