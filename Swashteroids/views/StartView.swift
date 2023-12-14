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
    let title: SwashSpriteNode
    let versionInfo: SKLabelNode

    init(gameSize: CGSize) {
        versionInfo = SKLabelNode(text: "Nyquist Art + Logic, LLC v\(appVersion) (build \(appBuild))")
        title = SwashSpriteNode(imageNamed: "title")
        noButtons = SwashSpriteNode(imageNamed: "nobuttons")
        buttons = SwashSpriteNode(imageNamed: "buttons")
		
		super.init(texture: nil, color: .clear, size: gameSize)
		anchorPoint = .zero
		zPosition = Layer.top.rawValue
		title.color = .white
		title.colorBlendFactor = 1.0
		title.position = CGPoint(x: size.width / 2, y: size.height / 2)
		title.position = CGPoint(x: size.width / 2, y: size.height / 2)


		let leftRocks = SKSpriteNode(imageNamed: "rocks_left")
		let rightRocks = SKSpriteNode(imageNamed: "rocks_right")
		let ship = SKSpriteNode(imageNamed: "ship")
		ship.alpha = 0
		ship.xScale = 0.75
		ship.yScale = 0.75
		ship.position = CGPoint(x: 512, y: 300)

		leftRocks.anchorPoint = CGPoint(x: 0, y: 1)
		rightRocks.anchorPoint = CGPoint(x: 0, y: 1)

		leftRocks.position = CGPoint(x: -leftRocks.frame.width, y: 768)
		rightRocks.position = CGPoint(x: 1024 + rightRocks.frame.width, y: 768)

		addChild(leftRocks)
		addChild(rightRocks)
		addChild(ship)

		let moveFromLeft = SKAction.move(to: CGPoint(x: 0, y: 768), duration: 0.25)
		let moveFromRight = SKAction.move(to: CGPoint(x: 1024 - rightRocks.size.width, y: 768), duration: 0.25)
		let group = SKAction.group([moveFromLeft, moveFromRight])

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
		addChild(buttons)
		addChild(noButtons)
		addChild(title)
		addChild(versionInfo)


        versionInfo.fontName = "Futura Condensed Medium"
        versionInfo.fontColor = .versionInfo
        versionInfo.fontSize = 21
        versionInfo.alpha = 0
        versionInfo.horizontalAlignmentMode = .center
        noButtons.anchorPoint = .zero
        noButtons.name = "nobuttons"
        noButtons.alpha = 0.2
        noButtons.position = CGPoint(x: 10, y: 50)
        buttons.anchorPoint = .zero
        buttons.name = "buttons"
        buttons.alpha = 0.2
        buttons.position = CGPoint(x: gameSize.width - buttons.size.width, y: 50)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
