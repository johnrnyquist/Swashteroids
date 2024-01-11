//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

@testable import Swashteroids

class MockPowerUpCreator: PowerUpCreator {
    var createHyperspacePowerUpCalled = false
    var createHyperspacePowerUpRadiusCalled = false
    var createPlasmaTorpedoesPowerUpCalled = false
    var createPlasmaTorpedoesPowerUpRadiusCalled = false

    func createHyperspacePowerUp(level: Int) {
        createHyperspacePowerUpCalled = true
    }

    func createHyperspacePowerUp(level: Int, radius: Double) {
        createHyperspacePowerUpRadiusCalled = true
    }

    func createPlasmaTorpedoesPowerUp(level: Int) {
        createPlasmaTorpedoesPowerUpCalled = true
    }

    func createPlasmaTorpedoesPowerUp(level: Int, radius: Double) {
        createPlasmaTorpedoesPowerUpRadiusCalled = true
    }
}

