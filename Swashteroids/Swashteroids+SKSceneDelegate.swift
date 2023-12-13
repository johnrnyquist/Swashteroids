//
//  Swashteroids+SKSceneDelegate.swift
//  Swashteroids
//
//  Created by John Nyquist on 12/11/23.
//

import Swash
import SpriteKit

extension Swashteroids: SKSceneDelegate {
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        dispatchTick() // This drives the game
        guard let data = motionManager.accelerometerData else { return }
        switch data.acceleration.y * orientation {
            case let y where y > 0.05:
                undo_right()
                do_left(data.acceleration.y * orientation)
            case let y where y < -0.05:
                undo_left()
                do_right(data.acceleration.y * orientation)
            case -0.05...0.05:
                undo_left()
                undo_right()
            default:
                break
        }
    }

    func do_left(_ amount: Double = 0.35) {
        inputComponent.leftIsDown = (true, amount)
    }

    func undo_left() {
        inputComponent.leftIsDown = (false, 0.0)
    }

    func do_right(_ amount: Double = -0.35) {
        inputComponent.rightIsDown = (true, amount)
    }

    func undo_right() {
        inputComponent.rightIsDown = (false, 0.0)
    }
}
