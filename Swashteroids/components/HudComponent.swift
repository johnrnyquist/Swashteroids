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

/// This is really a special DisplayComponent.
final class HudComponent: Component {
    private var hudView: HudView?

    init(hudView: HudView?) {
        self.hudView = hudView
    }

    func setNumShips(_ ships: Int) {
        hudView?.setNumShips(ships)
    }

    func setScore(_ score: Int) {
        hudView?.setScore(score)
    }

    func setLevel(_ level: Int) {
        hudView?.setLevel(level)
    }

    func setJumps(_ jumps: Int) {
        hudView?.setJumps(jumps)
    }

    func setAmmo(_ torpedoes: Int) {
        hudView?.setAmmo(torpedoes)
    }

    public func getLevelText() -> String? {
        hudView?.getLevelText()
    }

    public func getScoreText() -> String? {
        hudView?.getScoreText()
    }
}
