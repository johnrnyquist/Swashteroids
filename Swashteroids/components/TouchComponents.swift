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

class TouchableComponent: Component {}

class ButtonBehaviorComponent: Component {
    var touchDown: ((SwashteroidsSpriteNode) -> ())?
    var touchUp: ((SwashteroidsSpriteNode) -> ())?
    var touchUpOutside: ((SwashteroidsSpriteNode) -> ())?
    var touchMoved: ((SwashteroidsSpriteNode, Bool) -> ())?

    init(touchDown: ((SwashteroidsSpriteNode) -> ())? = nil,
         touchUp: ((SwashteroidsSpriteNode) -> ())? = nil,
         touchUpOutside: ((SwashteroidsSpriteNode) -> ())? = nil,
         touchMoved: ((SwashteroidsSpriteNode, Bool) -> ())? = nil) {
        self.touchDown = touchDown
        self.touchUp = touchUp
        self.touchUpOutside = touchUpOutside
        self.touchMoved = touchMoved
    }
}