//#-hidden-code
import UIKit
import PlaygroundSupport

City.shared = City(side: 21)
let mainStreet = mainRoad()

//#-end-hidden-code
/*:
 **Goal:** Build a road and create a housing area, a commerce area and a park.
 
 Of course, to grow your city you need to build roads. Roads can be built from **anchors**. There are three anchors available on every road: `start`, `center` and `end`.
 
 On this page, you'll create a very small neighborhood with a few houses, a few shops and a park. First, you'll need to create a road on which you'll place your buildings:
 
 ````
 let marketSt = mainStreet.center.roadRight(length: 5, name: .marketSt)
 ````
 
 */
//#-code-completion(identifier, show, mainStreet)
//#-code-completion(keyword, hide, for, func, if, let, var, while)
//#-code-completion(identifier, hide, Area, AreaType, Assessment, Check, CityViewController, Location, Road, StreetName, mainRoad(), Anchor, City)
let marketSt = /*#-editable-code*/<#build a road#>/*#-end-editable-code*/
/*:
 Now that you have a road, it's time to grow a small community! Use building methods on roads to zone housing and commerce on **Market St**, and then place a park on **Main Street**.
 
 * Experiment:
 Try to use `.depth(2).buildLeft(.park)` when placing a park on **Main Street**
 
 */
//#-editable-code Build here

//#-end-editable-code
//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
proxy?.send(City.shared.encoded())

if let currentStatus = page.assessmentStatus, case .pass = currentStatus {
    // Already passed
} else {
    page.assessmentStatus = Check.second().status
}

//#-end-hidden-code
