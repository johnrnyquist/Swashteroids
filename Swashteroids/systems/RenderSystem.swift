//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import Swash

final class RenderSystem: System {
    weak var scene: GameScene!
    weak var nodes: NodeList?

    init(scene: GameScene) {
        self.scene = scene
    }

    override func addToEngine(engine: Engine) {
        nodes = engine.getNodeList(nodeClassType: RenderNode.self)
        var node = nodes?.head
        while let currentNode = node {
            addToDisplay(currentNode)
            node = currentNode.next
        }
        nodes?.nodeAdded.add(Listener(addToDisplay))
        nodes?.nodeRemoved.add(Listener(removeFromDisplay))
    }

    private func addToDisplay(_ node: Node) {
        guard
            let component = node[DisplayComponent.self],
            let sprite = component.sknode
        else { return }
        scene.addChild(sprite)
    }

    private func removeFromDisplay(_ node: Node) {
        guard
            let component = node[DisplayComponent.self],
            let sprite = component.sknode
        else { return }
        sprite.removeFromParent()
    }

    override func update(time: TimeInterval) {
        var renderNode = nodes?.head
        while let currentNode = renderNode {
            let displayDisplayComponent = currentNode[DisplayComponent.self]
            let sknode = displayDisplayComponent?.sknode
            let positionComponent = currentNode[PositionComponent.self]
            if let positionComponent = positionComponent {
                sknode?.position = positionComponent.position
                sknode?.zRotation = positionComponent.rotationDegrees * Double.pi / 180
                sknode?.zPosition = positionComponent.layer
            }
            renderNode = currentNode.next
        }
    }

    override func removeFromEngine(engine: Engine) {
        scene.removeAllChildren()
        scene.removeAllActions()
        scene.removeFromParent()
        scene = nil
        nodes = nil
        scene = nil
    }
}
