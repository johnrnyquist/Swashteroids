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

final class HyperspaceJumpSystem: ListIteratingSystem {
    private weak var engine: Engine?
    private weak var creator: PowerUpCreatorUseCase?
    
    init(engine: Engine, creator: PowerUpCreatorUseCase) {
        super.init(nodeClass: HyperspaceJumpNode.self)
        self.engine = engine
        self.creator = creator
        nodeUpdateFunction = updateNode
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let position = node[PositionComponent.self],
              let hyperspace = node[DoHyperspaceJumpComponent.self],
              let hyperspaceDrive = node[HyperspaceDriveComponent.self],
              let sprite = node[DisplayComponent.self]?.sprite
        else { return }
        position.x = hyperspace.x
        position.y = hyperspace.y
        node.entity?.remove(componentClass: DoHyperspaceJumpComponent.self)
        hyperspaceDrive.jumps -= 1
        node.entity?.add(component: AudioComponent(fileNamed: .hyperspace, actionKey: "hyperspace.wav"))
        doHyperspaceEffect(on: sprite)
    }

    private func doHyperspaceEffect(on sprite: SwashSpriteNode) {
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
