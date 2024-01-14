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
    var ammoView: AmmoView!
    var jumpsView: AmmoView!

    func setAmmo(_ ammo: Int) {
        guard ammoView.ammo != ammo else { return }
        ammoView.ammo = ammo
    }

    func setJumps(_ jumps: Int) {
        guard jumpsView.ammo != jumps else { return }
        jumpsView.ammo = jumps
    }

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
        // Ammo
        ammoView = AmmoView(circleColor: .powerUpTorpedo, size: gameSize, icon: TorpedoesPowerUpView(imageNamed: .torpedoPowerUp))
        ammoView.zPosition = .top
        ammoView.x = gameSize.width * 1 / 3 - ammoView.width
        ammoView.y = textY
        addChild(ammoView)
        // Jumps
        jumpsView = AmmoView(circleColor: .powerUpHyperspace, size: gameSize, icon: HyperspacePowerUpView(imageNamed: .hyperspacePowerUp))
        jumpsView.zPosition = .top
        jumpsView.x = gameSize.width * 3 / 4 - jumpsView.width
        jumpsView.y = textY
        addChild(jumpsView)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setScore(_ value: Int) {
        scoreLabel.text = "SCORE: \(value.formattedWithCommas)"
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

class AmmoView: SKSpriteNode {
    var ammo: Int = 0 {
        didSet {
            refresh()
        }
    }
    var circles: [SKShapeNode] = []
    let radius: CGFloat = 2.0
    var spacing: CGFloat = 0.0
    var startingPoint = CGPoint(x: 0.0, y: 0.0)
    let rows = 2
    let columns = 10
    let padding: CGFloat = 3.0
    var icon: SKSpriteNode!
    
    func refresh() {
        for (index, circle) in circles.enumerated() {
            circle.isHidden = index >= ammo
        }
        icon.isHidden = ammo == 0
    }

    convenience init(circleColor: UIColor, size: CGSize, icon: SKSpriteNode) {
        self.init(texture: nil, color: .clear, size: size)
        self.icon = icon
        createCircles(circleColor, icon)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        spacing = radius * 2.0 + padding
        startingPoint = CGPoint(x: radius, y: radius)
        let rectWidth = CGFloat(columns) * spacing + padding
        let rectHeight = CGFloat(rows) * spacing + padding
        let rectangle = CGRect(x: 0, y: 0, width: rectWidth, height: rectHeight)
        super.init(texture: texture,
                   color: .clear,
                   size: CGSize(width: rectangle.width, height: rectangle.height))
        anchorPoint = .zero
    }

    func createCircles(_ color: UIColor, _ icon: SKSpriteNode) {
        addChild(icon)
        icon.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        icon.y = padding
        icon.alpha = 0.6
        for row in 0..<rows {
            for column in 0..<columns {
                let circle = SKShapeNode(circleOfRadius: radius)
                circle.fillColor = color
                circle.strokeColor = .clear
                circle.position = CGPoint(
                    x: startingPoint.x + CGFloat(column) * spacing + padding,
                    y: startingPoint.y + CGFloat(row) * spacing + padding
                )
                circle.isHidden = true
                circles.append(circle)
                addChild(circle)
            }
        }
        refresh()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
