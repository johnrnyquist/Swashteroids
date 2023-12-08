//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

//import Foundation
//import Swash
//import SpriteKit
//
//final class WaitForStartSystem: System {
//    private weak var engine: Engine?
//    private weak var creator: Creator?
//    private weak var gameNodes: NodeList?
//    private weak var waitNodes: NodeList?
//    private weak var asteroids: NodeList?
//	private weak var scene: SKScene!
//
//	init(_ creator: Creator, scene: SKScene) {
//        self.creator = creator
//		self.scene = scene
//    }
//
//    override public func addToEngine(engine: Engine) {
//        self.engine = engine
//        waitNodes = engine.getNodeList(nodeClassType: WaitForStartNode.self)
//        gameNodes = engine.getNodeList(nodeClassType: AppStateNode.self)
//        asteroids = engine.getNodeList(nodeClassType: AsteroidCollisionNode.self)
//    }
//
//    override public func update(time: TimeInterval) {
//        guard let waitNode = waitNodes?.head,
//			  let waitView = waitNode[DisplayComponent.self]?.displayObject as? WaitForStartView,
//              let input = waitNode[InputComponent.self],
//              let gameNode = gameNodes?.head,
//              let appStateComponent = gameNode[AppStateComponent.self]
//        else { return }
//
//        if input.tapped {
//            input.tapped = false
//            if input.noButtonsIsDown == false && input.buttonsIsDown == false {
//                return
//            }
//            if input.noButtonsIsDown {
//                if waitView.quadrants.alpha == 0 {
//                    //TODO: Transition to NOBUTTONS_INFO
//                    waitView.showQuadrants()
//                    return
//                } else {
//                    waitView.hideQuadrants()
//					creator?.createToggleButtonsButton(.hide)
//                }
//            } else if input.buttonsIsDown {
//                if waitView.buttonsInfo.alpha == 0 {
//                    //TODO: Transition to BUTTONS_INFO
//                    waitView.showButtonsInfo()
//                    return
//                } else {
//                    waitView.hideButtonsInfo()
//					creator?.createToggleButtonsButton(.show)
//                }
//            }
//            //TODO: Transition to PLAYING
//            appStateComponent.resetBoard()
//            appStateComponent.playing = true
//            engine?.removeEntity(entity: waitNode.entity!)
//            creator?.createHud(gameState: appStateComponent)
//        }
//    }
//
//    override public func removeFromEngine(engine: Engine) {
//        self.engine = nil
//        creator = nil
//        gameNodes = nil
//        waitNodes = nil
//        asteroids = nil
//    }
//}
