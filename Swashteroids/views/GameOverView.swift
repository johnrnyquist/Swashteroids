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
        gameOver.fontColor = .gameOverText
        gameOver.horizontalAlignmentMode = .center
        return gameOver
    }()

    init(gameSize: CGSize, scaleManager: ScaleManaging = ScaleManager.shared) {
        super.init(texture: nil, color: .clear, size: gameSize)
        let background = SKSpriteNode(color: .clear, size: gameSize)  
        background.name = "gameOverBackground"
        print(background.size, background.frame.size, background.scale)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.scale = 2
        addChild(background)
        name = "gameOverView"
        addChild(gameOver)
        gameOver.fontSize = 150.0
        let swash = SKSpriteNode(imageNamed: "swash")
        swash.name = "swash"
        swash.anchorPoint = CGPoint(x: 0.5, y: 1)
        swash.scale = scaleManager.SCALE_FACTOR == 1.0 ? 0.8 : 1.0
        swash.alpha = 0.2
        swash.y = gameOver.y - 30
        addChild(swash)
        zPosition = .top
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


