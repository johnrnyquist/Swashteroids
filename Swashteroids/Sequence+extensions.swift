//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation

extension Sequence {
    @discardableResult
    func printEach(_ prefix: String = "") -> [Element] {
        let array = Array(self)
        array.forEach { print("\(prefix)\($0)") }
        return array
    }
}