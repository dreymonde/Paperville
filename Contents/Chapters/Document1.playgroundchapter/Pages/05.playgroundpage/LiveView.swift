
import PlaygroundSupport

let page = PlaygroundPage.current

let mainStreet = mainRoad()

let vc = CityViewController(isEconomicsEnabled: true)
page.liveView = vc
