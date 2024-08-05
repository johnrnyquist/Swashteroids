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
import SpriteKit

final class HudSystem: ListIteratingSystem {
    private weak var gunNodes: NodeList?
    private weak var hyperspaceNodes: NodeList?
    private weak var engine: Engine?
    private weak var powerUpCreator: PowerUpCreatorUseCase?

    init(powerUpCreator: PowerUpCreatorUseCase) {
        super.init(nodeClass: HudNode.self)
        self.powerUpCreator = powerUpCreator
        nodeUpdateFunction = updateNode
    }

    override public func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
        gunNodes = engine.getNodeList(nodeClassType: GunNode.self)
        hyperspaceNodes = engine.getNodeList(nodeClassType: HyperspaceDriveNode.self)
    }

    func updateNode(_ hudNode: Node, _ time: TimeInterval) {
        guard let hudComponent = hudNode[HudComponent.self],
              let appStateComponent = engine?.gameStateComponent
        else { return }
        hudComponent.setNumShips(appStateComponent.numShips)
        hudComponent.setScore(appStateComponent.score)
        hudComponent.setLevel(appStateComponent.level)
        //
        if let gunNodes {
            var gunNode = gunNodes.head
            while let currentGunNode = gunNode {
                updateForGunNode(gunComponent: currentGunNode[GunComponent.self], shipEntity: gunNode?.entity, hudComponent: hudComponent)
                gunNode = currentGunNode.next
            }
        }
        if let hyperspaceNode = hyperspaceNodes?.head {
            updateForHyperspaceNode(hyperspaceComponent: hyperspaceNode[HyperspaceDriveComponent.self], hudComponent: hudComponent)
        }
    }

    func updateForHyperspaceNode(hyperspaceComponent: HyperspaceDriveComponent?, hudComponent: HudComponent) {
        if let hyperspaceComponent {
            hudComponent.setJumps(hyperspaceComponent.jumps)
            if hyperspaceComponent.jumps == 0 {
                hyperspaceNodes?.head?.entity?.remove(componentClass: HyperspaceDriveComponent.self)
                powerUpCreator?.createPowerUp(level: 1, type: .hyperspace, avoiding: nil) //TODO: get real level
                if let hyperspaceButton = engine?.findEntity(named: .hyperspaceButton),
                   engine?.gameStateComponent.shipControlsState == .usingScreenControls { //HACK
                    engine?.remove(entity: hyperspaceButton)
                }
            }
        }
    }

    func updateForGunNode(gunComponent: GunComponent?, shipEntity: Entity?, hudComponent: HudComponent) {
        if let gunComponent,
           gunComponent.ownerType == .player {
            hudComponent.setAmmo(gunComponent.numTorpedoes)
            if gunComponent.numTorpedoes == 0 {
                shipEntity?.remove(componentClass: GunComponent.self)
                powerUpCreator?.createPowerUp(level: 1, type: .torpedoes, avoiding: shipEntity?[PositionComponent.self]?.point) //TODO: get real level 
                if let fireButton = engine?.findEntity(named: .fireButton),
                   engine?.gameStateComponent.shipControlsState == .usingScreenControls { //HACK
                    engine?.remove(entity: fireButton)
                }
            }
        }
    }
}

