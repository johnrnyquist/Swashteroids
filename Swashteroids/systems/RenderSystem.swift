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

protocol Container: AnyObject {
    func addChild(_ node: SKNode)
    var children: [SKNode] { get }
}

final class RenderSystem: System {
    weak var container: Container!
    weak var nodes: NodeList?

    init(container: Container) {
        self.container = container
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
        container.addChild(sprite)
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
        nodes = nil
        container = nil
    }
}
