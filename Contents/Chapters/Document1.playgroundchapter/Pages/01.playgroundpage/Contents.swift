//: Design your own city in Swift code!
//#-hidden-code
import PlaygroundSupport

City.shared = City(side: 21)
let mainStreet = mainRoad()

//#-end-hidden-code
/*:
 Welcome to **Paperville**! In this book, you will create a few simple cities using only the Swift programming language. We'll start with basic building blocks of every city, and then we'll discover how different elements of the city work with each other.
 
 On this page, you're going to build your first housing area. Areas can be placed on the sides of the roads using `buildLeft` or `buildRight`.
 
 ````
 mainStreet.buildRight(.housing)
 ````
 
 * callout(Tip):
 You can drag your finger to move around the city and pinch to zoom in and out. Feel free to explore!
 
 */
mainStreet.buildLeft(.park)
//#-code-completion(identifier, show, mainStreet)
//#-code-completion(keyword, hide, for, func, if, let, var, while)
//#-code-completion(identifier, hide, Area, AreaType, Assessment, Check, CityViewController, Location, Road, StreetName, mainRoad(), Anchor, City)
//#-editable-code Build here

//#-end-editable-code
//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
proxy?.send(City.shared.encoded())

if let currentStatus = page.assessmentStatus, case .pass = currentStatus {
    // Already passed
} else {
    page.assessmentStatus = Check.first().status
}

//#-end-hidden-code
