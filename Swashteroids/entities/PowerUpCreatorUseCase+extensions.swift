//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//
extension PowerUpCreatorUseCase {
    func createHyperspacePowerUp(level: Int) {
        createHyperspacePowerUp(level: level, radius: POWER_UP_RADIUS)
    }

    func createShieldsPowerUp() {
        createShieldsPowerUp(radius: POWER_UP_RADIUS)
    }

    func createTorpedoesPowerUp(level: Int) {
        createTorpedoesPowerUp(level: level, radius: POWER_UP_RADIUS)
    }

    func createXRayPowerUp(level: Int) {
        createXRayPowerUp(level: level, radius: POWER_UP_RADIUS)
    }
}
