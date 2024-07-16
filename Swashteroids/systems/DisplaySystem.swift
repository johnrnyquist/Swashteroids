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

final class DisplaySystem: System {
    weak var scene: GameScene!
    weak var nodes: NodeList?
//    let circles = SKSpriteNode()

    init(scene: GameScene) {
        self.scene = scene
//        circles.name = "circles"
//        circles.anchorPoint = .zero
//        scene.addChild(circles)
    }

    override func addToEngine(engine: Engine) {
        nodes = engine.getNodeList(nodeClassType: DisplayNode.self)
        var node = nodes?.head
        while let currentNode = node {
            addToDisplay(currentNode)
            node = currentNode.next
        }
        nodes?.nodeAdded.add(Listener(addToDisplay))
        nodes?.nodeRemoved.add(Listener(removeFromDisplay))
    }

    private func addToDisplay(_ node: Node) {
        guard let sknode = node[DisplayComponent.self]?.sknode
        else { return }
        scene.addChild(sknode)
    }

    private func removeFromDisplay(_ node: Node) {
        guard let sknode = node[DisplayComponent.self]?.sknode
        else { return }
        sknode.removeFromParent()
    }

    override func update(time: TimeInterval) {
        var displayNode = nodes?.head
        while let currentNode = displayNode {
            let sknode = currentNode[DisplayComponent.self]?.sknode
            let positionComponent = currentNode[PositionComponent.self]
            if let positionComponent = positionComponent {
                sknode?.position = positionComponent.point
                sknode?.zRotation = positionComponent.rotationDegrees * Double.pi / 180
                sknode?.zPosition = positionComponent.layer
            }
            displayNode = currentNode.next
        }
//        circles.removeAllChildren()
//        let foos = scene.children
//                        .compactMap { $0 as? SwashSpriteNode }
//                        .compactMap { $0.entity }
//                        .filter { $0.has(componentClass: CollidableComponent.self) }
//        for foo in foos {
//            guard let point = foo[PositionComponent.self]?.point,
//                  let radius = foo[CollidableComponent.self]?.radius
//            else { continue }
//            let circle = SKShapeNode(circleOfRadius: CGFloat(radius))
//            circle.position = point
//            circle.strokeColor = .red
//            circle.lineWidth = 1
//            circle.zPosition = .top
//            circles.addChild(circle)
//        }
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
