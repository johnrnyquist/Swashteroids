//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation.NSDate
import Swash

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

/// The entity with the x-ray vision has this
final class XRayVisionComponent: Component {}

final class XRayVisionNode: Node {
    required init() {
        super.init()
        components = [
            XRayVisionComponent.name: nil,
        ]
    }
}

// This system needs two different nod types. TreasureInfoNode and XRayVisionNode. 
// Entities of different types are required at the moment.
// The player has XRay vision and the asteroids have the treasure info.
final class XRayVisionSystem: ListIteratingSystem {
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
        //HACK I'm brute forcing the application colors at-the-moment
        guard let sprite = node[DisplayComponent.self]?.sprite
        else { return }
        sprite.color = .asteroid
        sprite.colorBlendFactor = 1.0
        guard let treasureInfo = node[TreasureInfoComponent.self]?.type,
              let _ = xRayNodes?.head
        else { return }
        sprite.color = treasureInfo.color
        sprite.colorBlendFactor = 1.0
    }
}

