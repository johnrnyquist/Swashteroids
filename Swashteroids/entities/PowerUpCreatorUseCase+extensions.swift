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
    var powerUpRadius: Double { 7.0 }

    func createHyperspacePowerUp(level: Int) {
        createHyperspacePowerUp(level: level, radius: powerUpRadius)
    }

    func createShieldsPowerUp() {
        createShieldsPowerUp(radius: powerUpRadius)
    }

    func createTorpedoesPowerUp(level: Int) {
        createTorpedoesPowerUp(level: level, radius: powerUpRadius)
    }

    func createXRayPowerUp(level: Int) {
        createXRayPowerUp(level: level, radius: powerUpRadius)
    }
}
