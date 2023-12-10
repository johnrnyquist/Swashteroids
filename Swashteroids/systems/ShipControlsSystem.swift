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
import SpriteKit
import Foundation
import CoreMotion

final class ShipControlsSystem: ListIteratingSystem {
    let scene: GameScene!
    private weak var engine: Engine!
    
    init(scene: GameScene) {
        self.scene = scene
        super.init(nodeClass: ShipControlsStateNode.self)
        nodeUpdateFunction = updateNode
    }
    
    override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        self.engine = engine
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let transition = node[ChangeShipControlsStateComponent.self]
        else { return }
        do_toggleButtons(transition.to)
        node.entity?.remove(componentClass: ChangeShipControlsStateComponent.self)
    }

    //HACK this whole method is a hack, the Law of Demeter is being violated.
    func do_toggleButtons(_ to: ShipControlsState) {
        switch to {
            case .showingButtons:
                engine.ship?.remove(componentClass: AccelerometerComponent.self)
                scene.game.creator.removeShipControlQuadrants()
                scene.motionManager = nil
                scene.game.createShipControlButtons()
                scene.game.enableShipControlButtons()
                if let ship = engine.ship,
                   ship.has(componentClassName: GunComponent.name) {
                    if let fireButton = engine.getEntity(named: .fireButton),
                       let sprite = fireButton.sprite{
                        sprite.alpha = 0.2
                    }
                }
                if let ship = engine.ship,
                   ship.has(componentClassName: HyperSpaceEngineComponent.name) {
                    if let hyperSpaceButton = engine.getEntity(named: .hyperSpaceButton),
                       let sprite = hyperSpaceButton.sprite{
                        sprite.alpha = 0.2
                    }
                }
                scene.game.creator.removeToggleButton()
                scene.game.creator.createToggleButton(.on)
            case .hidingButtons:
                engine.ship?.add(component: AccelerometerComponent())
                scene.game.creator.createShipControlQuadrants()
                scene.motionManager = CMMotionManager()
                scene.motionManager?.startAccelerometerUpdates()
                scene.game.removeShipControlButtons()
                scene.game.creator.removeToggleButton()
                scene.game.creator.createToggleButton(.off)
        }
    }
}

