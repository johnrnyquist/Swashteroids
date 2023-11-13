import SpriteKit
import Swash


class HudView: SKNode {
    private var score: SKLabelNode!
    private var lives: SKLabelNode!
    private var level: SKLabelNode!

    override init() {
        super.init()
        score = createTextField()
        score.horizontalAlignmentMode = .center
        score.x = 512
        score.y = 700
        addChild(score)
        lives = createTextField()
        lives.x = 12
        lives.y = 700
        addChild(lives)
        level = createTextField()
        level.horizontalAlignmentMode = .right
        level.y = 700
        level.x = 1012
        addChild(level)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setScore(_ value: Int) {
        score.text = "SCORE: \(value)"
    }

    func setLives(_ value: Int) {
        lives.text = "LIVES: \(value)"
    }

    func setLevel(_ value: Int) {
        level.text = "LEVEL: \(value)"
    }

    private func createTextField() -> SKLabelNode {
        let tf = SKLabelNode()
        tf.horizontalAlignmentMode = .left
        tf.fontName = "Helvetica"
        tf.color = .white
        tf.fontSize = 36
        return tf
    }
}



