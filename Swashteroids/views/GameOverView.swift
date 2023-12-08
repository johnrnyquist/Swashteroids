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

class GameOverView: SwashteroidsSpriteNode {
    lazy private var gameOver: SKLabelNode = {
        let gameOver = SKLabelNode(text: "Game Over")
        gameOver.fontName = "Badloc ICG"
        gameOver.fontColor = .waitText
        gameOver.fontSize = 96
        gameOver.horizontalAlignmentMode = .center
        gameOver.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        return gameOver
    }()

    init(size: CGSize) {
        super.init(texture: nil, color: .clear, size: size)
        name = "gameOver"
        anchorPoint = .zero
        addChild(gameOver)
        zPosition = Layers.top.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


