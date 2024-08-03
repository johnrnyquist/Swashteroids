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

/// Used to intiate the creation of an X-Ray Power-Up
final class DoCreateXRayPowerUpComponent: Component {}

/// The game logs the creation of X-Ray Power-Ups and stores it here.
/// It notes when one has been created for a level.
/// This is a game rule: X-Ray Power-Ups appear at most, once per level. They will not appear if player already has one.
final class XRayPowerUpsLevelLogComponent: Component {
    var levels: [Int] = []
}

final class CreateXRayPowerUpNode: Node {
    required init() {
        super.init()
        components = [
            DoCreateXRayPowerUpComponent.name: nil,
            XRayPowerUpsLevelLogComponent.name: nil,
            GameStateComponent.name: nil,
        ]
    }
}

/// Creates an X-Ray Power-Up when a CreateXRayPowerUpNode is found.
/// This is mainly du to the presence of DoCreateXRayPowerUpComponent.
/// It usese XRayPowerUpsLevelLogComponent and GameStateComponent from the Node
/// and uses XRayPowerUpNodes and XRayVisionNodes.
final class CreateXRayPowerUpSystem: ListIteratingSystem {
    var powerUpCreator: PowerUpCreatorUseCase?
    var powerUpNodes: NodeList?
    var visionNodes: NodeList?

    init(powerUpCreator: PowerUpCreatorUseCase) {
        self.powerUpCreator = powerUpCreator
        super.init(nodeClass: CreateXRayPowerUpNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        powerUpNodes = engine.getNodeList(nodeClassType: XRayPowerUpNode.self)
        visionNodes = engine.getNodeList(nodeClassType: XRayVisionNode.self)
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let entity = node.entity,
              let xRayPowerUpsCreatedComponent = node[XRayPowerUpsLevelLogComponent.self],
              let level = node[GameStateComponent.self]?.level
        else { return }
        entity.remove(componentClass: DoCreateXRayPowerUpComponent.self)
        if powerUpNodes?.empty == true, // There are no xray powerup nodes floating around
           visionNodes?.empty == true, // Player does not have xray vision
           level > 2,  
           !xRayPowerUpsCreatedComponent.levels.contains(level) // A powerup for this level has not been created
        {
            xRayPowerUpsCreatedComponent.levels.append(level)
            powerUpCreator?.createPowerUp(level: level, type: .xRay)
        }
    }
}

