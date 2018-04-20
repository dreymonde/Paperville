//#-hidden-code
import UIKit
import PlaygroundSupport

let mainStreet = mainRoad()

//#-end-hidden-code
/*:
 **Goal:** Design a city with at least **5 factories** and **30 houses** having more than **90% average comfort score** and **economic balance** value greater than **0.9**.
 
 And also to have fun 😄
 
 Now, when you know all the tools to design your perfect city, as well as the rules that make it work, it's time to get your hands dirty.

 * callout(Urbanism):
 Applying some of the modern urbanism techniques — for example, making your neighborhoods _denser_ and decreasing the average block size (by making _more intersections_) will help you achieve better results.
 
 Code below is fully editable — feel free to create anything you want!
 
 * callout(Tip):
 Want to start from scratch, but feel too lazy to delete all this code? Simply go to the [next page](@next)
 
 */
//#-code-completion(identifier, show, mainStreet, redesign)
//#-code-completion(keyword, hide, while)
//#-code-completion(identifier, hide, Assessment, Check, CityViewController, Location, mainRoad(), City)
//#-editable-code Let's get to work!
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


//#-end-editable-code
/*:
 
 * Experiment:
 There are plenty of advanced features that can help you in creating diverse, flexible and accurate city layouts. Try these out:
 
 ````
 mainStreet.segment.between(thirdSt, and: elmSt).buildLeft(.housing)
 
 mainStreet.segment.before(thirdStreet).buildLeft(.commerce)
 
 mainStreet.reversed[0...2].buildRight(.housing)
 
 let firstSt = pineSt.end.road(to: mainStreet, name: .firstSt)

 ````
 
 */
//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
proxy?.send(City.shared.encoded())

if let currentStatus = page.assessmentStatus, case .pass = currentStatus {
    // Already passed
} else {
    page.assessmentStatus = Check.fourth().status
}

//#-end-hidden-code
