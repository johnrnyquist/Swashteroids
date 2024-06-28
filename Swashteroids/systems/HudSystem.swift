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
        hyperspaceNodes = engine.getNodeList(nodeClassType: HyperspaceNode.self)
    }

    func updateNode(_ hudNode: Node, _ time: TimeInterval) {
        guard let hudComponent = hudNode[HudComponent.self],
              let appStateComponent = engine?.appStateComponent
        else { return }
        hudComponent.hudView.setNumShips(appStateComponent.numShips)
        hudComponent.hudView.setScore(appStateComponent.score)
        hudComponent.hudView.setLevel(appStateComponent.level)
        //
        guard let gunNodes else { return }
        var gunNode = gunNodes.head
        while let currentGunNode = gunNode {
            updateForGunNode(currentGunNode[GunComponent.self], gunNode?.entity, hudNode)
            gunNode = currentGunNode.next
        }
        guard let hyperspaceNode = hyperspaceNodes?.head else { return }
        updateForHyperspaceNode(hyperspaceNode[HyperspaceDriveComponent.self], hudNode)
    }

    func updateForHyperspaceNode(_ hyperspaceComponent: HyperspaceDriveComponent?, _ hudNode: Node?) {
        if let hyperspaceComponent {
            hudNode?[HudComponent.self]?.hudView.setJumps(hyperspaceComponent.jumps)
            if hyperspaceComponent.jumps == 0 {
                hyperspaceNodes?.head?.entity?.remove(componentClass: HyperspaceDriveComponent.self)
                powerUpCreator?.createHyperspacePowerUp(level: 1) //TODO: get real level
                if let hyperspaceButton = engine?.findEntity(named: .hyperspaceButton),
                   engine?.appStateComponent.shipControlsState == .usingScreenControls { //HACK
                    engine?.remove(entity: hyperspaceButton)
                }
            }
        }
    }

    func updateForGunNode(_ gunComponent: GunComponent?, _ shipEntity: Entity?, _ hudNode: Node?) {
        if let gunComponent,
           gunComponent.ownerType == .player {
            hudNode?[HudComponent.self]?.hudView.setAmmo(gunComponent.numTorpedoes)
            if gunComponent.numTorpedoes == 0 {
                shipEntity?.remove(componentClass: GunComponent.self)
                powerUpCreator?.createTorpedoesPowerUp(level: 1) //TODO: get real level 
                if let fireButton = engine?.findEntity(named: .fireButton),
                   engine?.appStateComponent.shipControlsState == .usingScreenControls { //HACK
                    engine?.remove(entity: fireButton)
                }
            }
        }
    }
}

