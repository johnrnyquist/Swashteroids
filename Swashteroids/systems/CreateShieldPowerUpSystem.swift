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

/// Used to initiate the creation of an X-Ray Power-Up
final class DoCreateShieldPowerUpComponent: Component {}

/// The entity being shielded has this
final class ShieldComponent: Component {
    let maxCollisions = 3
    var strength = 3
}

final class ShieldPowerUpComponent: Component {}

final class CreateShieldPowerUpNode: Node {
    required init() {
        super.init()
        components = [
            DoCreateShieldPowerUpComponent.name: nil,
            ShieldPowerUpsLevelLogComponent.name: nil,
            GameStateComponent.name: nil,
        ]
    }
}

final class ShieldPowerUpNode: Node {
    required init() {
        super.init()
        components = [
            ShieldPowerUpComponent.name: nil,
            CollidableComponent.name: nil,
            PositionComponent.name: nil,
        ]
    }
}

final class ShieldNode: Node {
    required init() {
        super.init()
        components = [
            ShieldComponent.name: nil,
            PositionComponent.name: nil,
            DisplayComponent.name: nil,
            CollidableComponent.name: nil,
        ]
    }
}

final class ShieldPowerUpsLevelLogComponent: Component {
    var levels: [Int] = []
}

/// Creates an X-Ray Power-Up when a CreateXRayPowerUpNode is found.
/// This is mainly du to the presence of DoCreateXRayPowerUpComponent.
/// It usese XRayPowerUpsLevelLogComponent and GameStateComponent from the Node
/// and uses XRayPowerUpNodes and XRayVisionNodes.
final class CreateShieldPowerUpSystem: ListIteratingSystem {
    private weak var powerUpCreator: PowerUpCreatorUseCase?
    private weak var powerUpNodes: NodeList?
    private weak var shieldNodes: NodeList?

    init(powerUpCreator: PowerUpCreatorUseCase) {
        self.powerUpCreator = powerUpCreator
        super.init(nodeClass: CreateShieldPowerUpNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        powerUpNodes = engine.getNodeList(nodeClassType: ShieldPowerUpNode.self)
        shieldNodes = engine.getNodeList(nodeClassType: ShieldNode.self)
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let entity = node.entity,
              let shieldPowerUpsCreatedComponent = node[ShieldPowerUpsLevelLogComponent.self],
              let level = node[GameStateComponent.self]?.level
        else { return }
        entity.remove(componentClass: DoCreateShieldPowerUpComponent.self)
        if powerUpNodes?.empty == true, // There are no xray powerup nodes floating around
           shieldNodes?.empty == true, // Player does not have xray vision
           level > 1, 
           !shieldPowerUpsCreatedComponent.levels.contains(level) // A powerup for this level has not been created
        {
            shieldPowerUpsCreatedComponent.levels.append(level)
            powerUpCreator?.createPowerUp(level: level, type: .shields)
        }
    }
}

