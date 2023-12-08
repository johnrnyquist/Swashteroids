import Swash
import SpriteKit
import Foundation
import CoreMotion

final class ShipControlsSystem: ListIteratingSystem {
    let scene: GameScene!

    init(scene: GameScene) {
        self.scene = scene
        super.init(nodeClass: ShipControlsStateNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let transition = node[ChangeShipControlsStateComponent.self]
        else { return }
        do_toggleButtons(transition.to)
        
        node.entity?.remove(componentClass: ChangeShipControlsStateComponent.self)
    }

    func do_toggleButtons(_ to: ShipControlsState) {
        let playSound = SKAction.playSoundFileNamed("toggle.wav", waitForCompletion: false)
        scene.run(playSound)
        switch to {
            case .showingButtons:
                scene.game.ship?.remove(componentClass: AccelerometerComponent.self)
                scene.game.creator.removeShipControlQuadrants()
                scene.motionManager = nil
                scene.game.createShipControlButtons()
                scene.game.enableShipControlButtons()
                scene.game.creator.removeToggleButtonsButton()
                scene.game.creator.createToggleButton(.on)
            case .hidingButtons:
                scene.game.ship?.add(component: AccelerometerComponent())   
                scene.game.creator.createShipControlQuadrants()
                scene.motionManager = CMMotionManager()
                scene.motionManager?.startAccelerometerUpdates()
                scene.game.removeShipControlButtons()
                scene.game.creator.removeToggleButtonsButton()
                scene.game.creator.createToggleButton(.off)
        }
    }
}

