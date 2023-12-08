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
// NO SWASH NEEDED FOR VIEWS

class StartView: SwashteroidsSpriteNode {

	let buttons: SwashteroidsSpriteNode
	let nobuttons: SwashteroidsSpriteNode
	let title: SwashteroidsSpriteNode
	let versionInfo: SKLabelNode

	init(scene: SKScene) {
		versionInfo = SKLabelNode(text: "Nyquist Art + Logic, LLC v\(appVersion) (build \(appBuild))")
		title = SwashteroidsSpriteNode(imageNamed: "title")
		nobuttons = SwashteroidsSpriteNode(imageNamed: "nobuttons")
		buttons = SwashteroidsSpriteNode(imageNamed: "buttons")

		super.init(texture: nil, color: .clear, size: scene.size)

		anchorPoint = .zero
		zPosition = Layers.top.rawValue

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
		nobuttons.alpha = 0.2
		nobuttons.position = CGPoint(x: 10, y: 50)

		buttons.anchorPoint = .zero
		buttons.name = "buttons"
		buttons.alpha = 0.2
		buttons.position = CGPoint(x: scene.size.width - buttons.size.width, y: 50)


		addChild(buttons)
		addChild(nobuttons)
		addChild(title)
		addChild(versionInfo)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
