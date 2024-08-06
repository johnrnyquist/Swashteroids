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

final class GameOverView: SwashSpriteNode {
    private var gameOverLabel: SKLabelNode = {
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
        gameOverLabel.y = gameSize.height / 3
        //
        let background = SKSpriteNode(color: .black, size: gameSize)
        background.alpha = 0.01
        let scaledContainer = SwashScaledSpriteNode(color: .clear, size: gameSize)
        //
        let swashLogo = SKSpriteNode(imageNamed: "swash")
        swashLogo.anchorPoint = CGPoint(x: 0.5, y: 1)
        swashLogo.scale = scaleManager.SCALE_FACTOR == 1.0 ? 0.8 : 1.0
        swashLogo.alpha = 0.2
        swashLogo.color = .systemBlue
        swashLogo.colorBlendFactor = 0.2
        swashLogo.y = gameOverLabel.y - 40
        //
        addChild(background)
        addChild(scaledContainer)
        scaledContainer.addChild(gameOverLabel)
        scaledContainer.addChild(swashLogo)
        //
        zPosition = .bottom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


