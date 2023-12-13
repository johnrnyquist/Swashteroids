//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import func Foundation.hypot
import struct Foundation.CGPoint

extension CGPoint {
    static func +(left: CGPoint, right: CGPoint) -> CGPoint {
        var sum = CGPoint()
        sum = CGPoint(x: (left.x + right.x), y: (left.y + right.y))
        return sum
    }

    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        var sum = CGPoint()
        sum = CGPoint(x: (left.x - right.x), y: (left.y - right.y))
        return sum
    }

    func distance(from other: CGPoint) -> Double {
        hypot(x - other.x, y - other.y)
    }
}
