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
import Swash
import SpriteKit

/// A system that removes entities after a certain amount of time.
final class LifetimeSystem: ListIteratingSystem {
    private var engine: Engine!

    init() {
        super.init(nodeClass: LifetimeNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    func executeAfterDelay(on node: SKNode, delay: TimeInterval, code: @escaping () -> Void) {
        let delayAction = SKAction.wait(forDuration: delay)
        let runBlockAction = SKAction.run(code)
        let sequenceAction = SKAction.sequence([delayAction, runBlockAction])
        node.run(sequenceAction)
    }

    func fadeInAndOut(node: SKNode, animationDuration: TimeInterval, totalDuration: TimeInterval, completion: @escaping () -> Void) {
        let fadeIn = SKAction.fadeIn(withDuration: animationDuration / 2)
        let fadeOut = SKAction.fadeOut(withDuration: animationDuration / 2)
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        let repeatForDuration = SKAction.repeat(sequence, count: Int(totalDuration / animationDuration))

        node.run(repeatForDuration) {
            completion()
        }
    }
    func updateNode(node: Node, time: TimeInterval) {
        guard let component = node[LifetimeComponent.self],
              let display = node[DisplayComponent.self],
              let sknode = display.sknode,
              let entity = node.entity
        else { return }
        component.timeRemaining -= time
        if component.timeRemaining <= 0 {
            entity.remove(componentClass: LifetimeComponent.self)
            fadeInAndOut(node: sknode, animationDuration: 0.25, totalDuration: 2) {
                self.executeAfterDelay(on: sknode, delay: 3) {
                    self.engine.remove(entity: entity)
                }
            }
        }
    }
}

