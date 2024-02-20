//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//
protocol ShipButtonControlsManagerUseCase: AnyObject {
    func createShipControlButtons()
    func enableShipControlButtons()
    func removeShipControlButtons()
    func showFireButton()
    func showHyperspaceButton()
}

protocol ShipQuadrantsControlsManagerUseCase: AnyObject {
    func createShipControlQuadrants()
    func removeShipControlQuadrants()
}

protocol ToggleShipControlsManagerUseCase: AnyObject {
    func createToggleButton(_ toggleState: Toggle)
    func removeToggleButton()
}
