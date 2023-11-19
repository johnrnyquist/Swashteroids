import Swash

public class InputComponent: Component {
    var flipIsDown: Bool
    var leftIsDown: Bool
    var rightIsDown: Bool
    var thrustIsDown: Bool
    var triggerIsDown: Bool
    var aftTriggerIsDown: Bool
    var tapped: Bool

    init(flipIsDown: Bool = false,
         leftIsDown: Bool = false,
         rightIsDown: Bool = false,
         thrustIsDown: Bool = false,
         triggerIsDown: Bool = false,
         aftTriggerIsDown: Bool = false,
         tapped: Bool = false) 
    {
        self.flipIsDown = flipIsDown
        self.leftIsDown = leftIsDown
        self.rightIsDown = rightIsDown
        self.thrustIsDown = thrustIsDown
        self.triggerIsDown = triggerIsDown
        self.aftTriggerIsDown = aftTriggerIsDown
        self.tapped = tapped
    }
}
