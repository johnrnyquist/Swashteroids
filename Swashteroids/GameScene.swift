//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit
import Swash
import GameController

extension GameScene: SoundPlaying {}

class GameScene: SKScene {
    weak var touchDelegate: TouchDelegate?

    deinit {
        removeAllActions()
        removeFromParent()
        removeAllChildren()
        NotificationCenter.default.removeObserver(self)
    }

//    var cameraNode: SKCameraNode!
    override func didMove(to view: SKView) {
                super.didMove(to: view)
        backgroundColor = .background
//        cameraNode = SKCameraNode()
//        camera = cameraNode
//        cameraNode.setScale(1.0)
//        cameraNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
//        addChild(cameraNode)
    }

    //MARK:- TOUCHES -------------------------
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesEnded(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesMoved(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchDelegate?.touchesCancelled(touches, with: event)
    }

    override var isUserInteractionEnabled: Bool {
        get { true }
        set {}
    }
}
