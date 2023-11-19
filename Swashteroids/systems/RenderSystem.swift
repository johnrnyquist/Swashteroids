import SpriteKit
import Swash


final class RenderSystem: System {
    private weak var scene: SKScene!
    private weak var nodes: NodeList?

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
            let sprite = component.displayObject
        else { return }
        scene.addChild(sprite)
    }

    private func removeFromDisplay(_ node: Node) {
        guard
            let component = node[DisplayComponent.self],
            let sprite = component.displayObject
        else { return }
        sprite.removeFromParent()
    }

    override func update(time: TimeInterval) {
        var renderNode = nodes?.head
        while renderNode != nil {
            let displayDisplayComponent = renderNode?[DisplayComponent.self]
            let sprite = displayDisplayComponent?.displayObject
            let positionComponent = renderNode?[PositionComponent.self]
            if let positionComponent = positionComponent {
                sprite?.position = positionComponent.position
                sprite?.zRotation = positionComponent.rotation * Double.pi / 180
                sprite?.zPosition = positionComponent.zPosition.rawValue
            }
            renderNode = renderNode!.next
        }
    }

    override func removeFromEngine(engine: Engine) {
        nodes = nil
        scene = nil
    }
}
