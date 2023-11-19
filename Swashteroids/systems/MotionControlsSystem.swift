import Foundation
import SpriteKit
import Swash


class MotionControlsSystem: ListIteratingSystem {

    init() {
        super.init(nodeClass: MotionControlsNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard
            let position = node[PositionComponent.self],
            let motion = node[MotionComponent.self],
            let engine = node[WarpDriveComponent.self],
            let control = node[MotionControlsComponent.self],
            let audio = node[AudioComponent.self],
			let input = node[InputComponent.self]
        else { print("ALERT: \(node) is not \(MotionControlsNode.self)"); return }
		if input.flipIsDown {
			position.rotation += 180
			input.flipIsDown = false
		}
		if input.leftIsDown {
			position.rotation += control.rotationRate * time
		}
        if input.rightIsDown {
            position.rotation -= control.rotationRate * time
        }
        if input.thrustIsDown,
           engine.isThrusting == false {
            engine.isThrusting = true
            let thrustOnce = SKAction.playSoundFileNamed("thrust.wav", waitForCompletion: true)
            let thrust = SKAction.repeatForever(thrustOnce)
            audio.addSoundAction(thrust, withKey: "thrust")
        }
        if input.thrustIsDown,
           engine.isThrusting == true {
            let rot = position.rotation * Double.pi / 180.0
            motion.velocity.x += cos(rot) * control.accelerationRate * time
            motion.velocity.y += sin(rot) * control.accelerationRate * time
        } else if engine.isThrusting {
            engine.isThrusting = false
            audio.removeSoundAction("thrust")
        }
    }
}
