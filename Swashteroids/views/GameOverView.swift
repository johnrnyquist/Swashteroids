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
        gameOver.fontSize = 85.0
        return gameOver
    }()


    init(gameSize: CGSize, hitPercent: Int, scaleManager: ScaleManaging = ScaleManager.shared) {
        super.init(texture: nil, color: .clear, size: gameSize)
        scale = 1
        let background = SKSpriteNode(color: .clear, size: gameSize)
        background.name = "gameOverBackground"
        addChild(background)
        let container = SwashSpriteNode(color: .clear, size: gameSize)  
        container.name = "gameOverBackground"
        addChild(container)
        name = "gameOverView"
        container.addChild(gameOver)
        gameOver.y = size.height / 3
        //
        let swash = SKSpriteNode(imageNamed: "swash")
        swash.name = "swash"
        swash.anchorPoint = CGPoint(x: 0.5, y: 1)
        swash.scale = scaleManager.SCALE_FACTOR == 1.0 ? 0.8 : 1.0
        swash.alpha = 0.2
        swash.color = .systemBlue
        swash.colorBlendFactor = 0.2
        swash.y = gameOver.y - 40
        container.addChild(swash)
        zPosition = .top
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


