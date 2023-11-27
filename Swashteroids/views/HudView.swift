import SpriteKit


class HudView: SKNode {
    private var score: SKLabelNode!
    private var lives: SKLabelNode!
    private var level: SKLabelNode!

    override init() {
        super.init()
        score = createLabel()
        score.horizontalAlignmentMode = .center
        score.x = 512
        score.y = 700
        addChild(score)
        lives = createLabel()
        lives.x = 12
        lives.y = 700
        addChild(lives)
        level = createLabel()
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

    private func createLabel() -> SKLabelNode {
        let tf = SKLabelNode()
        tf.horizontalAlignmentMode = .left
        tf.fontName = "Badloc ICG"
		tf.fontColor = .hudText
        tf.fontSize = 48
        return tf
    }
}



