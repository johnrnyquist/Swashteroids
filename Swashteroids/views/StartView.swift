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

final class StartView: SwashSpriteNode {
    let play: SwashSpriteNode
    let tutorial: SwashSpriteNode
    let title: SKSpriteNode
    let versionInfo: SKLabelNode
    var versionInfoFontSize = 21.0

    init(gameSize: CGSize, scaleManager: ScaleManaging = ScaleManager.shared) {
        versionInfoFontSize *= scaleManager.SCALE_FACTOR
        // Initialize StartView constants
        versionInfo = SKLabelNode(text: "Nyquist Art + Logic, LLC v\(appVersion) (build \(appBuild))")
        title = SwashScaledSpriteNode(imageNamed: "title")
        tutorial = SwashScaledSpriteNode(imageNamed: "training")
        play = SwashScaledSpriteNode(imageNamed: "play")
        // Configure StartView
        super.init(texture: nil, color: .clear, size: gameSize)
        anchorPoint = .zero
        zPosition = .top
        // Configure title
        title.color = .white
        title.colorBlendFactor = 1.0
        title.position = CGPoint(x: size.width / 2, y: size.height / 2)
        // Configure rocks
        let leftRocks = SwashScaledSpriteNode(imageNamed: "rocks_left")
        leftRocks.scale *= 1.25
        leftRocks.anchorPoint = CGPoint(x: 0, y: 1)
        leftRocks.position = CGPoint(x: -leftRocks.frame.width, y: size.height)
        let rightRocks = SwashScaledSpriteNode(imageNamed: "rocks_right")
        rightRocks.scale *= 1.25
        rightRocks.anchorPoint = CGPoint(x: 0, y: 1)
        rightRocks.position = CGPoint(x: size.width + rightRocks.frame.width, y: size.height)
        // Configure ship
        let ship = SwashScaledSpriteNode(imageNamed: "ship")
        ship.alpha = 0
        ship.position = CGPoint(x: size.width / 2, y: size.height / 2 * 0.78)
        // Configure animations
        let moveFromLeft = SKAction.move(to: CGPoint(x: 0, y: size.height), duration: 0.25)
        let moveFromRight = SKAction.move(to: CGPoint(x: size.width - rightRocks.size.width, y: size.height), duration: 0.25)
        let destination = CGPoint(x: title.position.x, y: gameSize.height - title.size.height * 2)
        let bounceUpAction = SKAction.moveBy(x: 0, y: 10, duration: 0.07)
        let bounceDownAction = SKAction.moveBy(x: 0, y: -10, duration: 0.07)
        let moveAction = SKAction.move(to: destination, duration: 1.0)
        let waitAction = SKAction.wait(forDuration: 1.0)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.25)
        let seq2 = SKAction.sequence([fadeInAction, waitAction])
        moveAction.timingMode = .easeInEaseOut
        let titleSequence = SKAction.sequence([moveAction, bounceDownAction, bounceUpAction, bounceDownAction])
        title.run(titleSequence) {
            ship.run(fadeInAction)
            self.versionInfo.position = CGPoint(x: self.size.width / 2, y: self.title.y - self.title.size.height)
            self.versionInfo.run(seq2) {
                leftRocks.run(moveFromLeft)
                rightRocks.run(moveFromRight)
            }
        }
        // Configure versionInfo
        versionInfo.fontName = "Futura Condensed Medium"
        versionInfo.fontColor = .versionInfo
        versionInfo.fontSize = versionInfoFontSize
        versionInfo.alpha = 0
        versionInfo.horizontalAlignmentMode = .center
        // Configure buttons
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let window = appDelegate.window {
            tutorial.anchorPoint = .zero
            tutorial.name = "training"
            tutorial.alpha = 0.2
            tutorial.position = CGPoint(x: max(window.safeAreaInsets.left, 10), y: max(window.safeAreaInsets.bottom, 10))
            play.anchorPoint = .zero
            play.name = "buttons"
            play.alpha = 0.2
            play.position = CGPoint(x: gameSize.width - play.size.width - max(window.safeAreaInsets.right, 10),
                                       y: max(window.safeAreaInsets.bottom, 10))
        }
        // Add children
        addChild(leftRocks)
        addChild(rightRocks)
        addChild(ship)
//        addChild(buttons)
//        addChild(noButtons)
        addChild(title)
        addChild(versionInfo)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
