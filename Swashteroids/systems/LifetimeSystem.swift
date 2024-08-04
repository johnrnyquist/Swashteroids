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
/// Right now, this is really a TREASURE system because of the fading out action.
/// Need to rethink this.
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

    func fadeInAndOut(sknode: SKNode, animationDuration: TimeInterval, totalDuration: TimeInterval, completion: @escaping () -> Void) {
        let fadeIn = SKAction.fadeIn(withDuration: animationDuration / 2)
        let fadeOut = SKAction.fadeOut(withDuration: animationDuration / 2)
        let sequence = SKAction.sequence([fadeIn, fadeOut])
        let repeatForDuration = SKAction.repeat(sequence, count: Int(totalDuration / animationDuration))
        sknode.run(repeatForDuration) {
            completion()
        }
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let lifetime = node[LifetimeComponent.self],
              let sknode = node[DisplayComponent.self]?.sknode,
              let entity = node.entity
        else { return }
        lifetime.timeRemaining -= time
        if lifetime.timeRemaining <= 0 {
            entity.remove(componentClass: LifetimeComponent.self)
            fadeInAndOut(sknode: sknode, animationDuration: 0.25, totalDuration: 2) {
                self.engine.remove(entity: entity)
            }
        }
    }
}

