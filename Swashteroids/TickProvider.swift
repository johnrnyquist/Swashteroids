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
import Foundation

// Made a more simple tick provider that has a `Signaler1` instead of is a `Signaler1`. 
// It is given the current time instead of getting it from the system.
final public class TickProvider: ITickProvider {
    private var isPlaying: Bool = false
    private var previousTime: TimeInterval = 0
    private var signaler1: Signaler1 = Signaler1()
    public var timeAdjustment: Double = 1.0
    public var playing: Bool {
        isPlaying
    }
    
    public func dispatchTick(_ currentTime: TimeInterval) {
        guard isPlaying else { return }
        let frameTime: TimeInterval = (currentTime - previousTime) 
        previousTime = currentTime
        signaler1.dispatch(frameTime * timeAdjustment)
    }
    
    //MARK: - ITickProvider
    public func start() {
        previousTime = ProcessInfo.processInfo.systemUptime
        isPlaying = true
    }

    public func stop() {
        isPlaying = false
    }

    public func add(_ listener: Swash.Listener) {
        signaler1.add(listener)
    }

    public func remove(_ listener: Swash.Listener) {
        signaler1.remove(listener)
    }
}

