//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//
protocol ShipButtonControlsManager: AnyObject {
    func removeShipControlButtons()
    func createShipControlButtons()
    func enableShipControlButtons()
}

protocol ShipQuadrantsControlsManager: AnyObject {
    func removeShipControlQuadrants()
    func createShipControlQuadrants()
}

protocol ToggleShipControlsManager: AnyObject {
    func removeToggleButton()
    func createToggleButton(_ toggleState: Toggle)
}
