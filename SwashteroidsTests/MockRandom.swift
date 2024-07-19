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
@testable import Swashteroids

final class MockRandom: Randomizing {
    func nextDouble() -> Double { 0 }

    func nextInt(upTo max: Int) -> Int { 0 }

    func nextInt(from min: Int, upTo max: Int) -> Int { 0 }

    func nextInt(from min: Int, through max: Int) -> Int { 0 }

    func nextDouble(from min: Double, through max: Double) -> Double { 0 }

    func nextBool() -> Bool { false }
}
