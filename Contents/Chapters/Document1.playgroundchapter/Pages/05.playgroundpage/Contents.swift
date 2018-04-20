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

 */
//#-code-completion(identifier, show, mainStreet, redesign)
//#-code-completion(keyword, hide, while)
//#-code-completion(identifier, hide, Assessment, Check, CityViewController, Location, mainRoad(), City)
//#-editable-code Let's get to work!



//#-end-editable-code
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
