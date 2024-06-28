//
//  GCController+extensions.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/28/24.
//

import GameController

extension GameController {
    static func isGameControllerConnected() -> Bool {
        guard let controller = GCController.controllers().first,
              let controllerName = controller.vendorName,
              controllerName != "Gamepad"
        else { return false }
        return controller.isAttachedToDevice
    }
}
