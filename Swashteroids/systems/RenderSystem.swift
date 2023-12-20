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
    weak var scene: SKScene!
    weak var nodes: NodeList?

    init(container: SKScene) {
        scene = container
    }

    override func addToEngine(engine: Engine) {
        nodes = engine.getNodeList(nodeClassType: RenderNode.self)
        var node = nodes?.head
        while node != nil {
            addToDisplay(node!)
            node = node!.next
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
        while renderNode != nil {
            let displayDisplayComponent = renderNode?[DisplayComponent.self]
            let sknode = displayDisplayComponent?.sknode
            let positionComponent = renderNode?[PositionComponent.self]
            if let positionComponent = positionComponent {
                sknode?.position = positionComponent.position
                sknode?.zRotation = positionComponent.rotation * Double.pi / 180
                sknode?.zPosition = positionComponent.layer.rawValue
            }
            renderNode = renderNode!.next
        }
    }

    override func removeFromEngine(engine: Engine) {
        nodes = nil
        scene = nil
    }
}
