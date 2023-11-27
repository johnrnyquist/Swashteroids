import SpriteKit
import Swash


class WaitForStartView: SKSpriteNode {
    lazy private var titleText: SKLabelNode = {
        let gameOver = SKLabelNode(text: "Swashteroids!")
        gameOver.fontName = "Badloc ICG"
        gameOver.fontColor = .waitText
        gameOver.fontSize = 96
        gameOver.horizontalAlignmentMode = .center
		gameOver.position = CGPoint(x: size.width/2, y: size.height * 0.55)
        return gameOver
    }()
    lazy private var tapToStartText: SKLabelNode = {
        let clickToStart = SKLabelNode(text: "Tap to start")
        clickToStart.fontName = "Badloc ICG"
		clickToStart.fontColor = .waitText
        clickToStart.fontSize = 60
        clickToStart.horizontalAlignmentMode = .center
		clickToStart.position = CGPoint(x: size.width/2, y: size.height * 0.45)
        return clickToStart
    }()

	init(scene: SKScene) {
		super.init(texture: nil, color: .clear, size: scene.size)
		
        name = "wait"
        anchorPoint = .zero
		zPosition = Layers.wait.rawValue

		let title = SKSpriteNode(imageNamed: "title")
		title.color = .white
		title.colorBlendFactor = 1.0
		title.position = CGPoint(x: size.width/2, y: size.height/2)
		let destination = CGPoint(x: title.position.x, y: scene.size.height - title.size.height * 2)
		let moveAction = SKAction.move(to: destination, duration: 1.0)
		moveAction.timingMode = .easeInEaseOut 
		let bounceUpAction = SKAction.moveBy(x: 0, y: 10, duration: 0.07)
		let bounceDownAction = SKAction.moveBy(x: 0, y: -10, duration: 0.07)
		tapToStartText.alpha = 0
		let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
		let sequenceAction = SKAction.sequence([moveAction, bounceDownAction, bounceUpAction, bounceDownAction])
		title.run(sequenceAction) {
			self.tapToStartText.run(fadeInAction)
		}
		addChild(title)
		addChild(tapToStartText)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
