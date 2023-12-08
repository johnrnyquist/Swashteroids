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

final class HyperSpaceSystem: ListIteratingSystem {
    private var sound = SKAction.playSoundFileNamed("hyperspace.wav", waitForCompletion: false)
    private weak var scene: GameScene!

    init(scene: GameScene) {
        self.scene = scene
        super.init(nodeClass: HyperSpaceNode.self)
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let position = node[PositionComponent.self],
              let hyperSpace = node[HyperSpaceJumpComponent.self],
              let sprite = node[DisplayComponent.self]?.sprite
        else { return }
        position.position.x = hyperSpace.x
        position.position.y = hyperSpace.y
        node.entity?.remove(componentClass: HyperSpaceJumpComponent.self)
        scene.run(sound)
        doHyperSpaceEffect(on: sprite)
    }

    override public func removeFromEngine(engine: Engine) {
        scene = nil
    }

    private func doHyperSpaceEffect(on sprite: SwashteroidsSpriteNode) {
        let colorize = SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.25)
        let wait = SKAction.wait(forDuration: 0.5)
        let uncolorize = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.25)
        let sequence = SKAction.sequence([colorize, wait, uncolorize])
        let emitter = SKEmitterNode(fileNamed: "hyperspace.sks")!
        sprite.addChild(emitter)
        sprite.run(sequence) {
            emitter.removeFromParent()
        }
    }
}

