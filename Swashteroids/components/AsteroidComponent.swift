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

enum AsteroidSize {
    case small
    case medium
    case large
}

final class AsteroidComponent: Component {
    let size: AsteroidSize

    init(size: AsteroidSize) {
        self.size = size
        super.init()
    }

    func shrink() -> AsteroidSize {
        switch size {
        case .medium:
            return .small
        case .large:
            return .medium
        default:
            return .large // Should never happen
        }
    }
}
