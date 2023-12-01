import Foundation
import SpriteKit
import Swash
import CoreMotion

final class MotionControlsSystem: ListIteratingSystem {

    init() {
        super.init(nodeClass: MotionControlsNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard
            let position = node[PositionComponent.self],
            let motion = node[MotionComponent.self],
            let warpDrive = node[WarpDriveComponent.self],
            let control = node[MotionControlsComponent.self],
            let audio = node[AudioComponent.self],
			let input = node[InputComponent.self]
        else { print("ALERT: \(node) is not \(MotionControlsNode.self)"); return }
		if input.flipIsDown {
			position.rotation += 180
			input.flipIsDown = false
		}

//        position.rotation += control.rotationRate * (data.acceleration.y * 0.025)

        if input.leftIsDown.down {
            position.rotation += control.rotationRate * (input.leftIsDown.amount * 0.05)
//			position.rotation += control.rotationRate * time
		}
		if input.rightIsDown.down {
            position.rotation += control.rotationRate * (input.rightIsDown.amount * 0.05)
//			position.rotation -= control.rotationRate * time
		}

        if input.thrustIsDown,
           warpDrive.isThrusting == false {
            warpDrive.isThrusting = true
            let thrustOnce = SKAction.playSoundFileNamed("thrust.wav", waitForCompletion: true)
            let thrust = SKAction.repeatForever(thrustOnce)
            audio.addSoundAction(thrust, withKey: "thrust")
        }
        if input.thrustIsDown,
           warpDrive.isThrusting == true {
            let rot = position.rotation * Double.pi / 180.0
            motion.velocity.x += cos(rot) * control.accelerationRate * time
            motion.velocity.y += sin(rot) * control.accelerationRate * time
        } else if warpDrive.isThrusting {
            warpDrive.isThrusting = false
            audio.removeSoundAction("thrust")
        }
    }
}
