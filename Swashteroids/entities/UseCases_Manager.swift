//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//
protocol ShipButtonControlsCreatorUseCase: AnyObject {
    func createShipControlButtons()
    func enableShipControlButtons()
    func removeShipControlButtons()
    func showFireButton()
    func showHyperspaceButton()
}

protocol ShipQuadrantsControlsCreatorUseCase: AnyObject {
    func createShipControlQuadrants()
    func removeShipControlQuadrants()
}

protocol ToggleShipControlsCreatorUseCase: AnyObject {
    func createToggleButton(_ toggleState: Toggle)
    func removeToggleButton()
}
