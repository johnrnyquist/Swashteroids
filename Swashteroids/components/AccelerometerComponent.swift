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

final class AccelerometerComponent: Component {}

protocol Comp {
    init()
    static var name: String { get }
}

extension Comp {
    static var name: String {
        "\(Self.self)"
    }
}

struct MyStruct: Comp {
    init() {
        // Your implementation here
    }
}
