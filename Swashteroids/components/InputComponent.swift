import Swash

final public class InputComponent: Component {
    var hyperSpaceIsDown: Bool
    var flipIsDown: Bool
    var leftIsDown: Bool
    var rightIsDown: Bool
    var thrustIsDown: Bool
    var triggerIsDown: Bool
    var tapped: Bool

    init(hyperSpaceIsDown: Bool = false,
         flipIsDown: Bool = false,
         leftIsDown: Bool = false,
         rightIsDown: Bool = false,
         thrustIsDown: Bool = false,
         triggerIsDown: Bool = false,
         tapped: Bool = false) 
    {
        self.hyperSpaceIsDown = hyperSpaceIsDown
        self.flipIsDown = flipIsDown
        self.leftIsDown = leftIsDown
        self.rightIsDown = rightIsDown
        self.thrustIsDown = thrustIsDown
        self.triggerIsDown = triggerIsDown
        self.tapped = tapped
    }
}
