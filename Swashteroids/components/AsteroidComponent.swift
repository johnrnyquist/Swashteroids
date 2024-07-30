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

enum AsteroidSize: Double {
    case small = 13.5
    case medium = 27.0
    case large = 54.0
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
