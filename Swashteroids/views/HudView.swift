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
    var pauseButton: SwashSpriteNode!

    init(gameSize: CGSize, scaleManager: ScaleManaging = ScaleManager.shared) {
        super.init()

        var textY = gameSize.height - 65 * scaleManager.SCALE_FACTOR
        var textXPadding = 12.0 * scaleManager.SCALE_FACTOR

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let window = appDelegate.window {
            textXPadding += window.safeAreaInsets.left
            textY += window.safeAreaInsets.top
        }

        scoreLabel = createLabel(x: gameSize.width / 2, y: textY, alignment: .center)
        shipsLabel = createLabel(x: textXPadding, y: textY, alignment: .left)
        pauseButton = SwashSpriteNode(imageNamed: "pause")
        pauseButton.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        pauseButton.zPosition = .buttons
        pauseButton.x = gameSize.width - textXPadding
        pauseButton.y = textY
        pauseButton.scale = 0.25 //HACK
        levelLabel = createLabel(x: gameSize.width - textXPadding - pauseButton.width - 20.0, y: textY, alignment: .right)
        addChild(levelLabel)
        addChild(scoreLabel)
        addChild(shipsLabel)
        addChild(pauseButton)
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

    private func createLabel(text: String = "", x: Double = 0.0, y: Double = 0.0,
                             alignment: SKLabelHorizontalAlignmentMode = .center,
                             scaleManager: ScaleManaging = ScaleManager.shared) -> SKLabelNode {
        let label = SKLabelNode()
        label.horizontalAlignmentMode = .left
        label.fontName = "Futura Condensed Medium"
        label.fontColor = .hudText
        label.fontSize = 48 * scaleManager.SCALE_FACTOR
        label.horizontalAlignmentMode = alignment
        label.x = x
        label.y = y
        return label
    }
}



