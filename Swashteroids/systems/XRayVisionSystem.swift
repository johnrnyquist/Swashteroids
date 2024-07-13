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
import Foundation.NSDate

final class XRayPowerUpComponent: Component {}

final class XRayPowerUpNode: Node {
    required init() {
        super.init()
        components = [
            CollidableComponent.name: nil,
            PositionComponent.name: nil,
            XRayPowerUpComponent.name: nil,
        ]
    }
}

final class XRayVisionComponent: Component {}

class XRayVisionNode: Node {
    required init() {
        super.init()
        components = [
            XRayVisionComponent.name: nil,
        ]
    }
}

class TreasureInfoNode: Node {
    required init() {
        super.init()
        components = [
            TreasureInfoComponent.name: nil,
            DisplayComponent.name: nil,
        ]
    }
}

// This system needs two different nod types. TreasureInfoNode and XRayVisionNode. 
// Entities of different types are required at the moment.
// The player has XRay vision and the asteroids have the treasure info.
class XRayVisionSystem: ListIteratingSystem {
    private weak var xRayNodes: NodeList?

    init() {
        super.init(nodeClass: TreasureInfoNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        xRayNodes = engine.getNodeList(nodeClassType: XRayVisionNode.self)
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let sprite = node[DisplayComponent.self]?.sprite,
              let treasureInfo = node[TreasureInfoComponent.self]?.type,
                let _ = xRayNodes?.head
        else { return }
        sprite.color = treasureInfo.color
        sprite.colorBlendFactor = 1.0
    }
}

