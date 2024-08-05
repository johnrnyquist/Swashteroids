//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
@testable import Swashteroids

final class MockPowerUpCreator: PowerUpCreatorUseCase {
    var createHyperspacePowerUpCalled = false
    var createHyperspacePowerUpRadiusCalled = false
    var createTorpedoesPowerUpCalled = false
    var createTorpedoesPowerUpRadiusCalled = false
    var createPowerUpCalled = false

    func createPowerUp(level: Int, type: PowerUpType) {
        createPowerUpCalled = true
    }

    func createPowerUp(level: Int, type: PowerUpType, avoiding point: CGPoint? = nil) {
        createPowerUpCalled = true
    }

    func createHyperspacePowerUp(level: Int) {
        createHyperspacePowerUpCalled = true
    }

    func createHyperspacePowerUp(level: Int, radius: Double) {
        createHyperspacePowerUpRadiusCalled = true
    }

    func createTorpedoesPowerUp(level: Int) {
        createTorpedoesPowerUpCalled = true
    }

    func createTorpedoesPowerUp(level: Int, radius: Double) {
        createTorpedoesPowerUpRadiusCalled = true
    }
}

