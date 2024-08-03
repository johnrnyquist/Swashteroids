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
import GameplayKit

protocol Randomizing: AnyObject {
    func nextDouble() -> Double
    func nextInt(upTo max: Int) -> Int
    func nextInt(from min: Int, upTo max: Int) -> Int
    func nextInt(from min: Int, through max: Int) -> Int
    func nextDouble(from min: Double, through max: Double) -> Double
    func nextBool() -> Bool
}

/// `Randomness` is a class for generating random numbers. 
class Randomness: Randomizing {
    private let randomSource: GKRandomSource
    private let randomDistribution: GKRandomDistribution
    static private var randomness: Randomness!
    static var shared: Randomizing {
        if let randomness {
            return randomness
        } else {
            return initialize(with: Int(Date().timeIntervalSince1970))
        }
    }

    @discardableResult
    static func initialize(with seed: Int) -> Randomizing {
        randomness = Randomness(seed: UInt64(seed))
        return randomness
    }

    private init(seed: UInt64, lowestValue: Int = 0, highestValue: Int = Int.max) {
        randomSource = GKMersenneTwisterRandomSource(seed: seed)
        randomDistribution = GKRandomDistribution(randomSource: randomSource,
                                                       lowestValue: lowestValue,
                                                       highestValue: highestValue)
    }

    func nextDouble() -> Double {
        return Double(randomSource.nextUniform())
    }

    func nextInt(upTo max: Int) -> Int {
        return randomDistribution.nextInt(upperBound: max)
    }

    func nextInt(from min: Int, upTo max: Int) -> Int {
        return randomDistribution.nextInt(upperBound: max - min) + min
    }

    func nextInt(from min: Int, through max: Int) -> Int {
        return randomDistribution.nextInt(upperBound: max - min + 1) + min
    }

    func nextDouble(from min: Double, through max: Double) -> Double {
        return min + (Double(randomSource.nextUniform()) * (max - min))
    }

    func nextBool() -> Bool {
        return randomSource.nextBool()
    }
}
