
import PlaygroundSupport

let page = PlaygroundPage.current

let mainStreet = mainRoad()

let elmSt = mainStreet.firstHalf.secondHalf.center.roadLeft(length: 4, name: .elmSt)
let pineSt = elmSt.end.roadRight(length: 7, name: .pineSt)

pineSt.buildLeft(.housing)
pineSt.buildRight(.commerce)

elmSt.depth(3).buildRight(.park)
elmSt.depth(2).buildRight(.housing)
elmSt.buildRight(.commerce)
elmSt.depth(2).buildLeft(.commerce)

mainStreet.secondHalf
    .buildRight(.commerce)

let quartzSt = mainStreet[2]
    .roadRight(length: 7, name: .quartzSt)

quartzSt.buildRight(.housing)

let thirdSt = mainStreet[3]
    .roadLeft(length: 6, name: .thirdSt)

thirdSt.depth(2).buildLeft(.park)
thirdSt.secondHalf
    .depth(2).buildLeft(.housing)

let marketSt = mainStreet[6]
    .roadRight(length: 7, name: .marketSt)
let oakSt = marketSt.center
    .roadLeft(length: 7, name: .oakSt)

oakSt.secondHalf.buildRight(.housing)
oakSt.firstHalf.buildRight(.commerce)

let centralPark = mainStreet.segment
    .between(quartzSt, and: marketSt)
    .depth(6).buildRight(.park)

marketSt.segment.before(oakSt)
    .depth(3).buildLeft(.park)
marketSt.segment.after(oakSt)
    .buildLeft(.housing)
marketSt.secondHalf.buildRight(.commerce)

mainStreet.segment
    .between(quartzSt, and: marketSt)
    .buildRight(.housing)

let vc = CityViewController(isEconomicsEnabled: true)
page.liveView = vc
