//
//  GCController+extensions.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/28/24.
//

import GameController

extension GCController {
    //TODO: There is a more ECS way to do this, but I'm tired.
    static func isGameControllerConnected() -> Bool {
        guard let controller = GCController.controllers().first,
              // controller.isAttachedToDevice == true, // A Backbone One is attached
              let vendorName = controller.vendorName,
              vendorName != "Gamepad" // Gamepad is name of Simulator’s gamepad
        else {
            // The array below will show the Simulator’s gamepad if running on Simulator.
            print("NO CONTROLLERS DETECTED", GCController.controllers())
            return false
        }
        return true
    }
}
