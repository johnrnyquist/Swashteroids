//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import Swash

class TutorialMessageHandler {
    private let gameSize: CGSize
    private let tutorialText: Entity

    init(gameSize: CGSize, tutorialText: Entity) {
        self.gameSize = gameSize
        self.tutorialText = tutorialText
    }

    /// Displays a message on the screen and runs a sequence of actions.
    /// - Parameters:
    ///   - text: The message text to display.
    ///   - action: The action to perform after the message sequence completes.
    func callAsFunction(text: String, action: @escaping () -> Void) {
        tutorialText.remove(componentClass: PositionComponent.self)
        let skNode = tutorialText[DisplayComponent.self]!.sknode
        skNode.alpha = 1.0
        skNode.removeAllChildren()
        let label = createLabel(with: text)
        skNode.addChild(label)
        positionTutorialText(for: text)
        runMessageSequence(on: skNode, completion: action)
    }

    /// Creates a label node with the given text.
    /// - Parameter text: The text to display in the label.
    /// - Returns: A configured `SKLabelNode`.
    private func createLabel(with text: String) -> SKLabelNode {
        let label = SKLabelNode(attributedText: format(string: text))
        label.numberOfLines = 0
        return label
    }

    /// Positions the tutorial text on the screen.
    /// - Parameter text: The text to display.
    private func positionTutorialText(for text: String) {
        let y = gameSize.height - (24.0 * CGFloat((4 + text.components(separatedBy: "\n").count)))
        tutorialText.add(component: PositionComponent(x: gameSize.halfWidth, y: CGFloat(y), z: .top))
    }

    /// Runs a sequence of actions on the given node.
    /// - Parameters:
    ///   - node: The node to run the actions on.
    ///   - completion: The action to perform after the sequence completes.
    private func runMessageSequence(on node: SKNode, completion: @escaping () -> Void) {
        let wait3 = SKAction.wait(forDuration: 3)
        let wait1 = SKAction.wait(forDuration: 1)
        let fade = SKAction.fadeAlpha(to: 0.3, duration: 1)
        let seq = SKAction.sequence([wait3, fade, wait1])
        node.run(seq, completion: completion)
    }

    /// Formats the given string as an attributed string.
    /// - Parameter string: The string to format.
    /// - Returns: A formatted `NSAttributedString`.
    private func format(string: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: string)
        let range = NSRange(location: 0, length: attributed.length)
        let font = UIFont(name: "Futura Condensed Medium", size: 24.0)!
        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        attributed.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attributed.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        return NSAttributedString(attributedString: attributed)
    }
}