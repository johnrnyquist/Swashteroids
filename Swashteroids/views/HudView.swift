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

    init(gameSize: CGSize) {
        super.init()
        let textY = gameSize.height - 65
        let textXPadding = 12.0
        score = createLabel(x:gameSize.width / 2, y: textY, alignment: .center)
        addChild(score)
        ships = createLabel(x: textXPadding, y: textY, alignment: .left)
        addChild(ships)
        level = createLabel(x: gameSize.width - textXPadding, y: textY, alignment: .right)
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

    private func createLabel(text: String = "", x: Double = 0.0, y: Double = 0.0, alignment: SKLabelHorizontalAlignmentMode = .center) -> SKLabelNode {
        let tf = SKLabelNode()
        tf.horizontalAlignmentMode = .left
        tf.fontName = "Futura Condensed Medium"
        tf.fontColor = .hudText
        tf.fontSize = 48
        tf.horizontalAlignmentMode = alignment
        tf.x = x
        tf.y = y
        return tf
    }
}



