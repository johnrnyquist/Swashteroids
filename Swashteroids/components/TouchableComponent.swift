//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash

final class TouchableComponent: Component {}

final class ButtonBehaviorComponent: Component {
    var touchDown: ((SwashSpriteNode) -> ())?
    var touchUp: ((SwashSpriteNode) -> ())?
    var touchUpOutside: ((SwashSpriteNode) -> ())?
    var touchMoved: ((SwashSpriteNode, Bool) -> ())?

    init(touchDown: ((SwashSpriteNode) -> ())? = nil,
         touchUp: ((SwashSpriteNode) -> ())? = nil,
         touchUpOutside: ((SwashSpriteNode) -> ())? = nil,
         touchMoved: ((SwashSpriteNode, Bool) -> ())? = nil) {
        self.touchDown = touchDown
        self.touchUp = touchUp
        self.touchUpOutside = touchUpOutside
        self.touchMoved = touchMoved
    }
}
