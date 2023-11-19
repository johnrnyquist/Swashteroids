import SpriteKit
import Swash


class WaitForStartView: SKSpriteNode {
    private var gameOver: SKLabelNode = {
        let gameOver = SKLabelNode(text: "Swashteroids!")
        gameOver.fontName = "Helvetica"
        gameOver.fontColor = .waitText
        gameOver.fontSize = 72
        gameOver.horizontalAlignmentMode = .center
        gameOver.position = CGPoint(x: 512, y: 400)
        return gameOver
    }()
    private var clickToStart: SKLabelNode = {
        let clickToStart = SKLabelNode(text: "Tap to start")
        clickToStart.fontName = "Helvetica Light"
		clickToStart.fontColor = .waitText
        clickToStart.fontSize = 64
        clickToStart.horizontalAlignmentMode = .center
        clickToStart.position = CGPoint(x: 512, y: 330)
        return clickToStart
    }()

    init() {
        super.init(texture: nil, color: .clear, size: CGSize(width: 1024, height: 768))
        name = "wait"
        anchorPoint = .zero
        addChild(clickToStart)
        addChild(gameOver)
		zPosition = Layers.wait.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
