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
        gameOver.horizontalAlignmentMode = .center
        return gameOver
    }()
    let scaleManager: ScaleManaging

    init(size: CGSize, scaleManager: ScaleManaging = ScaleManager.shared) {
        self.scaleManager = scaleManager
        super.init(texture: nil, color: .clear, size: size)
        name = "gameOverView"
        addChild(gameOver)
        gameOver.fontSize = 150.0
        let swash = SKSpriteNode(imageNamed: "swash")
        swash.anchorPoint = CGPoint(x: 0.5, y: 1)
        swash.scale = scaleManager.SCALE_FACTOR == 1.0 ? 0.8 : 1.0
        swash.alpha = 0.2
        swash.y = gameOver.y - 30
        addChild(swash)
        zPosition = Layer.top.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


