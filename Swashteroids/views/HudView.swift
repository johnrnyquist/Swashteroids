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

/// HudView is not visual, it's an SKNode, its children are.
class HudView: SKNode {
    private var levelLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var shipsLabel: SKLabelNode!

    init(gameSize: CGSize) {
        super.init()
        let textY = gameSize.height - 65 * SCALE_FACTOR
        let textXPadding = 12.0 * SCALE_FACTOR
        levelLabel = createLabel(x: gameSize.width - textXPadding, y: textY, alignment: .right)
        scoreLabel = createLabel(x: gameSize.width / 2, y: textY, alignment: .center)
        shipsLabel = createLabel(x: textXPadding, y: textY, alignment: .left)
        addChild(levelLabel)
        addChild(scoreLabel)
        addChild(shipsLabel)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setScore(_ value: Int) {
        scoreLabel.text = "SCORE: \(value)"
    }

    func setNumShips(_ value: Int) {
        shipsLabel.text = "SHIPS: \(value)"
    }

    func setLevel(_ value: Int) {
        levelLabel.text = "LEVEL: \(value)"
    }

    func getScoreText() -> String {
        scoreLabel.text ?? ""
    }

    func getNumShipsText() -> String {
        shipsLabel.text ?? ""
    }

    func getLevelText() -> String {
        levelLabel.text ?? ""
    }

    private func createLabel(text: String = "", x: Double = 0.0, y: Double = 0.0, alignment: SKLabelHorizontalAlignmentMode = .center) -> SKLabelNode {
        let label = SKLabelNode()
        label.horizontalAlignmentMode = .left
        label.fontName = "Futura Condensed Medium"
        label.fontColor = .hudText
        label.fontSize = 48 * SCALE_FACTOR
        label.horizontalAlignmentMode = alignment
        label.x = x
        label.y = y
        return label
    }
}



