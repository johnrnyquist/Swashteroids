import SpriteKit
import Swash


final class DisplayComponent: Component {
    private(set) var sknode: SKNode?

    init(sknode: SKNode) {
        self.sknode = sknode
    }
    
    // There are several types that could be displayed, i.e. SKSpriteNode, SKShapeNode, SKLabelNode, etc 
    // so I chose the root type. A downside is down casting. Here are a couple computed properties.
    var sprite: SwashteroidsSpriteNode? { sknode as? SwashteroidsSpriteNode}
    var label: SKLabelNode? { sknode as? SKLabelNode}
}
