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
 
/// When specifying types in Node classes, the exact type is required.
/// So ButtonComponent subclasses will not be treated as ButtonComponent as far as the Engine is concerned.
/// This is why you will see ButtonComponent along with a subclass sometimes in a Node class.
class ButtonComponent: Component {
    var tapCount = 0
}

// TODO I considered namespacing the below but decided to keep it simple.
//MARK: - Gameplay buttons
final class ButtonFireComponent: ButtonComponent {}

final class ButtonFlipComponent: ButtonComponent {}

final class ButtonHyperspaceComponent: ButtonComponent {}

final class ButtonLeftComponent: ButtonComponent {}

final class ButtonRightComponent: ButtonComponent {}

final class ButtonThrustComponent: ButtonComponent {}

final class ButtonPauseComponent: ButtonComponent {}

final class ButtonToggleComponent: ButtonComponent {}

//MARK: - Alert popup buttons
final class ButtonHomeComponent: ButtonComponent {}

final class ButtonResumeComponent: ButtonComponent {}

final class ButtonSettingsComponent: ButtonComponent {}

//MARK: - Start and info screen buttons
final class ButtonPlayComponent: ButtonComponent {}

final class ButtonWithButtonsComponent: ButtonComponent {}

final class ButtonWithAccelerometerComponent: ButtonComponent {}

final class ButtonWithButtonsInfoComponent: ButtonComponent {}

final class ButtonWithAccelerometerInfoComponent: ButtonComponent {}

//MARK: - GameOver only
final class ButtonGameOverToHomeComponent: ButtonComponent {}
