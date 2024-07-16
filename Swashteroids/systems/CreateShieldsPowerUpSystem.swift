//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import Swash

/// Used to initiate the creation of an X-Ray Power-Up
class DoCreateShieldsPowerUpComponent: Component {}

/// The entity being shielded has this
class ShieldsComponent: Component {
    let max = 3
    var strength = 3
}

class ShieldsPowerUpComponent: Component {}

class CreateShieldsPowerUpNode: Node {
    required init() {
        super.init()
        components = [
            DoCreateShieldsPowerUpComponent.name: nil,
        ]
    }
}

class ShieldsPowerUpNode: Node {
    required init() {
        super.init()
        components = [
            CollidableComponent.name: nil,
            PositionComponent.name: nil,
            ShieldsPowerUpComponent.name: nil,
        ]
    }
}

class ShieldsNode: Node {
    required init() {
        super.init()
        components = [
            ShieldsComponent.name: nil,
            PositionComponent.name: nil,
            DisplayComponent.name: nil,
            CollidableComponent.name: nil,
        ]
    }
}

/// Creates an X-Ray Power-Up when a CreateXRayPowerUpNode is found.
/// This is mainly du to the presence of DoCreateXRayPowerUpComponent.
/// It usese XRayPowerUpsLevelLogComponent and GameStateComponent from the Node
/// and uses XRayPowerUpNodes and XRayVisionNodes.
final class CreateShieldsPowerUpSystem: ListIteratingSystem {
    private weak var powerUpCreator: PowerUpCreatorUseCase?
    private weak var powerUpNodes: NodeList?
    private weak var shieldsNodes: NodeList?

    init(powerUpCreator: PowerUpCreatorUseCase) {
        self.powerUpCreator = powerUpCreator
        super.init(nodeClass: CreateShieldsPowerUpNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        powerUpNodes = engine.getNodeList(nodeClassType: ShieldsPowerUpNode.self)
        shieldsNodes = engine.getNodeList(nodeClassType: ShieldsNode.self)
    }

    private func updateNode(node: Node, time: TimeInterval) {
        if powerUpNodes?.empty == true,
           shieldsNodes?.empty == true {
            powerUpCreator?.createShieldsPowerUp()
        }
    }
}

final class ShieldsSystem: ListIteratingSystem {
    private weak var shieldsNodes: NodeList?
    private weak var playerNodes: NodeList?

    init() {
        super.init(nodeClass: ShieldsNode.self)
        nodeUpdateFunction = updateNode
    }

    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        shieldsNodes = engine.getNodeList(nodeClassType: ShieldsNode.self)
        playerNodes = engine.getNodeList(nodeClassType: PlayerNode.self)
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let shieldsPosition = node[PositionComponent.self],
              let playerPosition = playerNodes?.head?.entity?[PositionComponent.self],
              let sprite = node[DisplayComponent.self]?.sprite,
              let shields = node[ShieldsComponent.self]
        else { return }
        shieldsPosition.x = playerPosition.x
        shieldsPosition.y = playerPosition.y
        sprite.alpha = CGFloat(shields.strength) / CGFloat(shields.max)
    }
}
