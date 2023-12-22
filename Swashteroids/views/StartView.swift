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

final class StartView: SwashSpriteNode {
	let buttons: SwashSpriteNode
	let noButtons: SwashSpriteNode
	let title: SKSpriteNode
	let versionInfo: SKLabelNode

	init(gameSize: CGSize) {
		// Initialize StartView constants
		versionInfo = SKLabelNode(text: "Nyquist Art + Logic, LLC v\(appVersion) (build \(appBuild))")
		title = SKSpriteNode(imageNamed: "title")
		noButtons = SwashSpriteNode(imageNamed: "nobuttons")
		buttons = SwashSpriteNode(imageNamed: "buttons")

		// Configure StartView
		super.init(texture: nil, color: .clear, size: gameSize)
		scale = 1 // clear the parent's setting
		anchorPoint = .zero
		zPosition = Layer.top.rawValue

		// Configure title
		title.scale *= SCALE_FACTOR
		title.color = .white
		title.colorBlendFactor = 1.0
		title.position = CGPoint(x: size.width / 2, y: size.height / 2)

		// Configure rocks
		let leftRocks = SKSpriteNode(imageNamed: "rocks_left")
		leftRocks.scale *= SCALE_FACTOR
		leftRocks.anchorPoint = CGPoint(x: 0, y: 1)
		leftRocks.position = CGPoint(x: -leftRocks.frame.width, y: size.height)

		let rightRocks = SKSpriteNode(imageNamed: "rocks_right")
		rightRocks.scale *= SCALE_FACTOR
		rightRocks.anchorPoint = CGPoint(x: 0, y: 1)
		rightRocks.position = CGPoint(x: size.width + rightRocks.frame.width, y: size.height)

		// Configure ship
		let ship = SKSpriteNode(imageNamed: "ship")
		ship.alpha = 0
		ship.scale *= 0.75 * SCALE_FACTOR
		ship.position = CGPoint(x: size.width/2, y: size.height/2 * 0.78)

		// Configure animations
		let moveFromLeft = SKAction.move(to: CGPoint(x: 0, y: size.height), duration: 0.25)
		let moveFromRight = SKAction.move(to: CGPoint(x: size.width - rightRocks.size.width, y: size.height), duration: 0.25)
		let destination = CGPoint(x: title.position.x, y: gameSize.height - title.size.height * 2)
		let bounceUpAction = SKAction.moveBy(x: 0, y: 10, duration: 0.07)
		let bounceDownAction = SKAction.moveBy(x: 0, y: -10, duration: 0.07)
		let moveAction = SKAction.move(to: destination, duration: 1.0)
		let waitAction = SKAction.wait(forDuration: 1.0)
		let fadeInAction = SKAction.fadeIn(withDuration: 0.25)
		let seq2 = SKAction.sequence([fadeInAction, waitAction])
		moveAction.timingMode = .easeInEaseOut
		let titleSequence = SKAction.sequence([moveAction, bounceDownAction, bounceUpAction, bounceDownAction])
		title.run(titleSequence) {
			ship.run(fadeInAction)
			self.versionInfo.position = CGPoint(x: self.size.width / 2, y: self.title.y - self.title.size.height)
			self.versionInfo.run(seq2) {
				leftRocks.run(moveFromLeft)
				rightRocks.run(moveFromRight)
			}
		}

		// Configure versionInfo
		versionInfo.fontName = "Futura Condensed Medium"
		versionInfo.fontColor = .versionInfo
		versionInfo.fontSize = 21 * SCALE_FACTOR
		versionInfo.alpha = 0
		versionInfo.horizontalAlignmentMode = .center

		// Configure buttons
		noButtons.anchorPoint = .zero
		noButtons.name = "nobuttons"
		noButtons.alpha = 0.2
		noButtons.position = CGPoint(x: 10, y: 50 * SCALE_FACTOR)
		buttons.anchorPoint = .zero
		buttons.name = "buttons"
		buttons.alpha = 0.2
		buttons.position = CGPoint(x: gameSize.width - buttons.size.width, y: 50 * SCALE_FACTOR)

		// Add children
		addChild(leftRocks)
		addChild(rightRocks)
		addChild(ship)
		addChild(buttons)
		addChild(noButtons)
		addChild(title)
		addChild(versionInfo)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
