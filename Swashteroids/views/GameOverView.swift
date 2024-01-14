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
    private var hitPercentage: SKLabelNode = {
        let label = SKLabelNode(text: "Hit Percentage")
        label.name = "gameOverLabel"
        label.fontName = "Futura-Medium"
        label.fontColor = .gameOverText
        label.horizontalAlignmentMode = .center
        label.fontSize = 36
        return label
    }()
    private var hitPercentageNum: SKLabelNode = {
        let label = SKLabelNode(text: "0%")
        label.name = "gameOverLabel"
        label.fontName = "Futura-Medium"
        label.fontColor = .gameOverText
        label.horizontalAlignmentMode = .center
        label.fontSize = 48
        return label
    }()

    init(gameSize: CGSize, hitPercent: Int, scaleManager: ScaleManaging = ScaleManager.shared) {
        super.init(texture: nil, color: .clear, size: gameSize.scaled(by: 2))
        let background = SKSpriteNode(color: .clear, size: gameSize.scaled(by: 2))  
        background.name = "gameOverBackground"
        addChild(background)
        name = "gameOverView"
        background.addChild(gameOver)
        gameOver.y = size.height / 4
        background.addChild(hitPercentage)
        background.addChild(hitPercentageNum)
        hitPercentage.y = gameOver.y - hitPercentage.frame.height * 1.7
        hitPercentage.text = "Your hit percentage:"
        hitPercentageNum.y = hitPercentage.y - hitPercentageNum.frame.height * 1.7
        hitPercentageNum.text = "\(hitPercent)%"
        //
        let swash = SKSpriteNode(imageNamed: "swash")
        swash.name = "swash"
        swash.anchorPoint = CGPoint(x: 0.5, y: 1)
        swash.scale = scaleManager.SCALE_FACTOR == 1.0 ? 0.8 : 1.0
        swash.alpha = 0.2
        swash.y = hitPercentageNum.y - 40
        background.addChild(swash)
        zPosition = .top
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


