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

class GameOverView: SwashSpriteNode {
	private var gameOver: SKLabelNode = {
        let gameOver = SKLabelNode(text: "Game Over")
		gameOver.name = "gameOverLabel"
        gameOver.fontName = "Badloc ICG"
        gameOver.fontColor = .waitText
        gameOver.fontSize = 96
        gameOver.horizontalAlignmentMode = .center
        return gameOver
    }()

    init(size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        name = "gameOverView"
        addChild(gameOver)
        zPosition = Layer.top.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


