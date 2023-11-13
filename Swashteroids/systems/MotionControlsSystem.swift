import Foundation
import SpriteKit
import Swash


class MotionControlsSystem: ListIteratingSystem {
    private var keyPoll: KeyPoll

    init(keyPoll: KeyPoll) {
        self.keyPoll = keyPoll
        super.init(nodeClass: MotionControlsNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard
            let position = node[PositionComponent.self],
            let motion = node[MotionComponent.self],
            let engine = node[EngineComponent.self],
            let control = node[MotionControlsComponent.self],
            let audio = node[AudioComponent.self]
        else { print("ALERT: \(node) is not \(MotionControlsNode.self)"); return }
        if keyPoll.leftIsDown {
            position.rotation += control.rotationRate * time
        }
        if keyPoll.rightIsDown {
            position.rotation -= control.rotationRate * time
        }
        if keyPoll.thrustIsDown,
           engine.isThrusting == false {
            engine.isThrusting = true
            let thrustOnce = SKAction.playSoundFileNamed("thrust.wav", waitForCompletion: true)
            let thrust = SKAction.repeatForever(thrustOnce)
            audio.addSoundAction(thrust, withKey: "thrust")
        }
        if keyPoll.thrustIsDown,
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
