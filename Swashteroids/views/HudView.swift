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


class HudView: SKNode {
    private var score: SKLabelNode!
    private var ships: SKLabelNode!
    private var level: SKLabelNode!

    override init() {
        super.init()
        score = createLabel()
        score.horizontalAlignmentMode = .center
        score.x = 512
        score.y = 700
        addChild(score)
        ships = createLabel()
        ships.x = 12
        ships.y = 700
        addChild(ships)
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

    func setNumShips(_ value: Int) {
        ships.text = "SHIPS: \(value)"
    }

    func setLevel(_ value: Int) {
        level.text = "LEVEL: \(value)"
    }

    private func createLabel() -> SKLabelNode {
        let tf = SKLabelNode()
        tf.horizontalAlignmentMode = .left
        tf.fontName = "Futura Condensed Medium"
		tf.fontColor = .hudText
        tf.fontSize = 48
        return tf
    }
}



