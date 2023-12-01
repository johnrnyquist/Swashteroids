import Swash

final public class InputComponent: Component {
	var showHideButtonsIsDown = false
	var hyperSpaceIsDown = false
	var flipIsDown = false
	var leftIsDown: (down: Bool, amount: Double) = (false, 0.0)
	var rightIsDown: (down: Bool, amount: Double ) = (false, 0.0)
	var thrustIsDown = false
	var triggerIsDown = false
	var noButtonsIsDown = false
	var buttonsIsDown = false
	var tapped = false
}
