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
              controller.isAttachedToDevice == true,
              let controllerName = controller.vendorName,
              controllerName != "Gamepad"
        else {
            print("NO CONTROLLERS DETECTED", GCController.controllers())
            return false
        }
        return controller.isAttachedToDevice
    }
}
