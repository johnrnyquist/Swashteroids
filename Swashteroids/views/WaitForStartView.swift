import SpriteKit
import Swash


class WaitForStartView: SKSpriteNode {

	let buttons: SKSpriteNode
	let nobuttons: SKSpriteNode
	let title: SKSpriteNode
	let versionInfo: SKLabelNode

	let buttonsInfo: SKNode
	let quadrants: SKNode

	init(scene: SKScene) {
		let nbscene = SKScene(fileNamed: "NoButtons.sks")!
		quadrants = nbscene.childNode(withName: "quadrants")!
		let bscene = SKScene(fileNamed: "ButtonsInfo.sks")!
		buttonsInfo = bscene.childNode(withName: "buttonsInfo")!
		versionInfo = SKLabelNode(text: "Nyquist Art + Logic, LLC v\(appVersion) (build \(appBuild))")
		title = SKSpriteNode(imageNamed: "title")
		nobuttons = SKSpriteNode(imageNamed: "nobuttons")
		buttons = SKSpriteNode(imageNamed: "buttons")

		super.init(texture: nil, color: .clear, size: scene.size)

		name = "wait"
		anchorPoint = .zero
		zPosition = Layers.wait.rawValue

		title.color = .white
		title.colorBlendFactor = 1.0
		title.position = CGPoint(x: size.width/2, y: size.height/2)
		title.position = CGPoint(x: size.width/2, y: size.height/2)

		let destination = CGPoint(x: title.position.x, y: scene.size.height - title.size.height * 2)
		let bounceUpAction = SKAction.moveBy(x: 0, y: 10, duration: 0.07)
		let bounceDownAction = SKAction.moveBy(x: 0, y: -10, duration: 0.07)
		let moveAction = SKAction.move(to: destination, duration: 1.0)
		let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
		moveAction.timingMode = .easeInEaseOut
		let titleSequence = SKAction.sequence([moveAction, bounceDownAction, bounceUpAction, bounceDownAction])

		title.run(titleSequence) {
			self.versionInfo.run(fadeInAction)
			self.versionInfo.position = CGPoint(x: self.size.width/2, y: self.title.y-self.title.size.height )
		}

		versionInfo.fontName = "Futura Condensed Medium"
		versionInfo.fontColor = .versionInfo
		versionInfo.fontSize = 21
		versionInfo.alpha = 0
		versionInfo.horizontalAlignmentMode = .center


		nobuttons.anchorPoint = .zero
		nobuttons.name = "nobuttons"
		nobuttons.alpha = 0.6
		nobuttons.position = CGPoint(x: 10, y: 50)

		buttons.anchorPoint = .zero
		buttons.name = "buttons"
		buttons.alpha = 0.6
		buttons.position = CGPoint(x: scene.size.width - buttons.size.width, y: 50)

		quadrants.removeFromParent()
		quadrants.alpha = 0

		buttonsInfo.removeFromParent()
		buttonsInfo.alpha = 0

		addChild(buttons)
		addChild(nobuttons)
		addChild(quadrants)
		addChild(title)
		addChild(versionInfo)
		addChild(buttonsInfo)
    }

	func hideQuadrants() {
		quadrants.removeFromParent()
	}

	func showQuadrants() {
		quadrants.alpha = 1
		buttons.removeFromParent()
		nobuttons.removeFromParent()
		title.removeFromParent()
		versionInfo.removeFromParent()
	}

	func hideButtonsInfo() {
		buttonsInfo.removeFromParent()
	}

	func showButtonsInfo() {
		buttonsInfo.alpha = 1
		buttons.removeFromParent()
		nobuttons.removeFromParent()
		title.removeFromParent()
		versionInfo.removeFromParent()
	}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
