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
import CoreMotion

final class GameScene: SKScene {
    static var sound = SKAudioNode(fileNamed: "thrust.wav") //HACK HACK HACK
    private var touchDelegate: TouchDelegate?
    var game: Swashteroids!
    var alertPresenter: AlertPresenter!
    
    
    override func didMove(to view: SKView) {
        print(#function)
        super.didMove(to: view)
        game = Swashteroids(scene: self, alertPresenter: alertPresenter)
        delegate = game
        touchDelegate = game
        //HACK to get around the SpriteKit bug where repeated sounds have a popping noise
        GameScene.sound.run(SKAction.changeVolume(to: 0, duration: 0))
        let addAudioNodeAction = SKAction.run { [unowned self] in
            GameScene.sound.removeFromParent()
            addChild(GameScene.sound)
        }
        run(addAudioNodeAction)
        //END_HACK
        backgroundColor = .background
        game.start()
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
