import SpriteKit
import Swash


class WaitForStartView: SKSpriteNode {
	lazy private var tapToStartText: SKLabelNode = {
		let label = SKLabelNode(text: "Tap to start")
		label.fontName = "Futura Condensed Medium"
		label.fontColor = .waitText
		label.fontSize = 60
		label.horizontalAlignmentMode = .center
		label.position = CGPoint(x: size.width/2, y: size.height * 0.45)
		return label
	}()
	lazy private var versionInfo: SKLabelNode = {
		let label = SKLabelNode(text: "v\(appVersion) (build \(appBuild))")
		label.fontName = "Futura Condensed Medium"
		label.fontColor = .versionInfo
		label.fontSize = 14
		label.horizontalAlignmentMode = .center
		label.position = CGPoint(x: size.width/2, y: 50)
		return label
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

		let node = SKNode()
		node.addChild(tapToStartText)
		node.addChild(versionInfo)
		node.alpha = 0

		let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
		let sequenceAction = SKAction.sequence([moveAction, bounceDownAction, bounceUpAction, bounceDownAction])

		addChild(node)

		title.run(sequenceAction) {
			node.run(fadeInAction)
		}
		addChild(title)

		let nobuttons = SKSpriteNode(imageNamed: "nobuttons")
		nobuttons.anchorPoint = .zero
		nobuttons.alpha = 0.6
		nobuttons.position = CGPoint(x: 10, y: 50)

		let buttons = SKSpriteNode(imageNamed: "buttons")
		buttons.anchorPoint = .zero
		buttons.alpha = 0.6
		buttons.position = CGPoint(x: scene.size.width - buttons.size.width, y: 50)
		addChild(buttons)
		addChild(nobuttons)


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
