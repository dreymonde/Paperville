//#-hidden-code
import UIKit
import PlaygroundSupport

City.shared = City(side: 30)
let mainStreet = mainRoad()

//#-end-hidden-code
/*:
 **Goal:** Revitalize your city by creating additional industrial jobs.
 
 Your city is an ecosystem. Your residents need a place to work. They need nearby places to eat, shop and relax. They also want to have neighbors, and they want to have parks within walking distance. All these wants and needs are encapsulated in a **comfort score** — an abstract number that shows how appealing a specific house (or rather its surrounding) is.
 
 * callout(Look!):
 Take a look at the city on the right. Just by looking at it you see that many houses are pale, which indicates low comfort. You can tap at any of them to reveal the exact reasons — **try it now**!
 
 You'll see that some residents are unemployed, and it makes them unhappy. By exploring different houses you can discover all the problems they might have.
 
 ![Showcase](showcase.jpeg)
 
 * callout(Tip):
 You may notice that when you tap on the house, everything outside its walking distance gets desaturated. Only areas within walking distance (apart from the work place) affect comfort score.
 
 Let's get more jobs to our city! We can easily solve the disbalance by placing a few industrial buildings.
 
 Luckily, we already have a perfect place to build our factories — an **Industrial St** at the bottom of the map. Place a few factories there, and see how the city instantly becomes vital again.
 
 ````
 industrialSt.buildRight(.industry)
 ````
 
 */
//#-code-completion(identifier, show, mainStreet)
//#-code-completion(keyword, hide, for, func, if, let, var, while)
//#-code-completion(identifier, hide, Area, AreaType, Assessment, Check, CityViewController, Location, Road, StreetName, mainRoad(), Anchor, City)
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

//#-editable-code Bring industry to Industrial Street!

//#-end-editable-code
/*:
 Looks much brighter now! Of course, the city still has its problems, but we solved the most important one.
 
 * Experiment:
 Try to build even more industrial buildings and see what happens with the industry when there are not enough population to fill all the jobs.
 
 */
//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
proxy?.send(City.shared.encoded())

if let currentStatus = page.assessmentStatus, case .pass = currentStatus {
    // Already passed
} else {
    page.assessmentStatus = Check.third().status
}

//#-end-hidden-code
