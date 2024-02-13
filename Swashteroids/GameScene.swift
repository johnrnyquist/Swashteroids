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

extension GameScene: SoundPlaying {}

extension GameScene: Container {}

final class GameScene: SKScene {
    static var sound = SKAudioNode(fileNamed: SoundFileNames.thrust.rawValue) //HACK HACK HACK
    var touchDelegate: TouchDelegate?
//    var cameraNode: SKCameraNode!

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setUpControllerObservers()
        //HACK to get around the SpriteKit bug where repeated sounds have a popping noise
        GameScene.sound.run(SKAction.changeVolume(to: 0, duration: 0))
        let addAudioNodeAction = SKAction.run { [unowned self] in
            GameScene.sound.removeFromParent()
            addChild(GameScene.sound)
        }
        run(addAudioNodeAction)
        //END_HACK
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
