import Swash

class TouchableComponent: Component {}

//class TouchDownActionComponent: Component {
//    var action: () -> ()
//
//    init(_ action: @escaping () -> ()) {
//        self.action = action
//    }
//}
//
//class TouchUpActionComponent: Component {
//    var action: () -> ()
//
//    init(_ action: @escaping () -> ()) {
//        self.action = action
//    }
//}

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