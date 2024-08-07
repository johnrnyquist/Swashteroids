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

/// HudView is not visual, it's an SKNode, its children are visual.
final class HudView: SKNode {
    private var levelLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var pauseButtonArt: SKSpriteNode!
    private var numShips = 0
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

    var textY = 0.0
    var textXPadding = 0.0

    init(gameSize: CGSize, scaleManager: ScaleManaging = ScaleManager.shared) {
        super.init()
        textY = gameSize.height - 65 * scaleManager.SCALE_FACTOR
        textXPadding = 12.0 * scaleManager.SCALE_FACTOR
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let window = appDelegate.window {
            textXPadding += window.safeAreaInsets.left
            textY += window.safeAreaInsets.top
        }
        scoreLabel = createLabel(x: gameSize.width / 2, y: textY, alignment: .center)
//        shipsLabel = createLabel(x: textXPadding, y: textY, alignment: .left)
        //
        // pauseButtonArt does nothing
        pauseButtonArt = AssetImage.pause.sprite
        pauseButtonArt.size = CGSize(width: scoreLabel.fontSize, height: scoreLabel.fontSize)
        pauseButtonArt.anchorPoint = CGPoint(x: 1, y: 1)
        pauseButtonArt.position = CGPoint(x: 0, y: 0)
        pauseButtonArt.zPosition = .top
        //
        // pauseButton is used by an Entity
        pauseButton = SwashSpriteNode(color: .clear, size: CGSize(width: 60, height: 60))
        pauseButton.alpha = 0.2
        pauseButton.anchorPoint = CGPoint(x: 1, y: 1)
        pauseButton.x = gameSize.width - textXPadding
        pauseButton.y = textY + 48 * scaleManager.SCALE_FACTOR
        pauseButton.zPosition = .buttons
        addChild(pauseButton)
        pauseButton.addChild(pauseButtonArt)
        //
        levelLabel = createLabel(x: gameSize.width - pauseButtonArt.width - textXPadding - pauseButtonArt.width,
                                 y: textY,
                                 alignment: .right)
        addChild(levelLabel)
        addChild(scoreLabel)
//        addChild(shipsLabel)
        // Ammo
        ammoView = AmmoView(circleColor: .powerUpTorpedo,
                            size: gameSize,
                            icon: TorpedoesPowerUpView(imageNamed: AssetImage.torpedoPowerUp.name))
        ammoView.zPosition = .top
        ammoView.x = gameSize.width * 1 / 3 - ammoView.width
        ammoView.y = textY
        addChild(ammoView)
        // Jumps
        jumpsView = AmmoView(circleColor: .powerUpHyperspace,
                             size: gameSize,
                             icon: HyperspacePowerUpView(imageNamed: AssetImage.hyperspacePowerUp.name))
        jumpsView.zPosition = .top
        jumpsView.x = gameSize.width * 3 / 4 - jumpsView.width
        jumpsView.y = textY
        addChild(jumpsView)
        let ships = SKNode()
        ships.position = CGPoint(x: textXPadding, y: textY)
        ships.name = "ships"
        addChild(ships)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setScore(_ value: Int) {
        scoreLabel.text = "SCORE: \(value.formattedWithCommas)"
    }

    func createShips(num: Int) {
        guard let ships = childNode(withName: "//ships"),
              numShips != num else { return }
        numShips = num
        ships.removeAllChildren()
        guard num > 0 else { return }
        for i in 1..<num {
            let ship = SwashScaledSpriteNode(texture: createShipTexture())
            ship.zRotation = Double.pi / 2.0
            ship.alpha = 0.5
            ship.scale *= 0.7
            ship.position = CGPoint(x: CGFloat(i) * ship.height, y: ship.width / 2)
            ships.addChild(ship)
        }
    }

    func setNumShips(_ value: Int) {
        createShips(num: value)
    }

    func setLevel(_ value: Int) {
        var val = value
        if val == 0 { val = 1 } //HACK
        levelLabel.text = "LEVEL: \(val)"
    }

    func getScoreText() -> String {
        scoreLabel.text ?? ""
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

final class AmmoView: SKSpriteNode {
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
