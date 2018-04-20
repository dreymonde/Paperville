
import PlaygroundSupport

let page = PlaygroundPage.current

City.shared = City(side: 21)

let mainStreet = mainRoad()

let vc = CityViewController(isEconomicsEnabled: false)
page.liveView = vc
