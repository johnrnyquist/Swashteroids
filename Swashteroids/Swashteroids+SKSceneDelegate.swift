//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import SpriteKit

extension Swashteroids: SKSceneDelegate {
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        dispatchTick() // This drives the game
        guard let data = motionManager?.accelerometerData else { return }
        switch data.acceleration.y * orientation {
            case let y where y > 0.05:
                rotateLeft(by: data.acceleration.y * orientation)
            case let y where y < -0.05:
                rotateRight(by: data.acceleration.y * orientation)
            case -0.05...0.05:
                clearRotate()
            default:
                break
        }
    }

    func rotateLeft(by amount: Double) {
        inputComponent.rotate = (true, amount)
    }

    func rotateRight(by amount: Double) {
        inputComponent.rotate = (true, amount)
    }

    func clearRotate() {
        inputComponent.rotate = (false, 0.0)
    }
}
