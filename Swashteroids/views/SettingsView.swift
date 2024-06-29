//
//  SettingsView.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/26/24.
//

import SwiftUI

enum GameCommand: String, CaseIterable {
    // Playing
    case fire = "Fire"
    case thrust = "Thrust"
    case hyperspace = "Hyperspace"
    case left = "Left"
    case right = "Right"
    case pause = "Pause"
    case flip = "Flip"
    // Alert
    case home = "Home"
    case resume = "Resume"
    case settings = "Settings"
    // Start
    case buttons = "Buttons"
    case noButtons = "No Buttons"
    // Info
    case `continue` = "Continue"
}

enum GameState: String, CaseIterable {
    case start = "Start Screen"
    case infoButtons = "Buttons Information Screen"
    case infoNoButtons = "No Buttons Information Screen"
    case playing = "Playing Screen"
    case gameOver = "Game Over Screen"
    var commandsPerScreen: [GameCommand] {
        switch self {
            case .start:
                return [.buttons, .noButtons]
            case .infoButtons:
                return [.continue]
            case .infoNoButtons:
                return [.continue]
            case .playing:
                return [.fire, .thrust, .hyperspace, .left, .right, .pause, .flip]
            case .gameOver:
                return [.pause, .home, .settings, .resume]
        }
    }
}

struct SettingsView: View {
    @State private var gameCommandToElementName: [GameCommand: String] = [:] // This should be loaded from persistent storage

    
    @State private var currentMapping: GameCommand? = nil
    @State private var currentAppState: GameState = .playing

    let hide: () -> Void
    let gamePadManager: GamePadManager?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    hide()
                }.padding()
            }
            Text("Settings")
                    .font(.title)
            Picker("Swashteroids State", selection: $currentAppState) {
                ForEach(GameState.allCases, id: \.self) { state in
                    Text(state.rawValue).tag(state)
                }
            }
            List(currentAppState.commandsPerScreen, id: \.self) { command in
                HStack {
                    Text(command.rawValue)
                    Spacer()
                    Button(action: {
                        currentMapping = command
                    }) {
                        HStack {
                            if let sfSymbolName = gamePadManager!.elementNameToSymbolName[gameCommandToElementName[command] ?? ""] {
                                Image(systemName: sfSymbolName)
                            }
                            Text(gameCommandToElementName[command] ?? "Not Set")
                        }
                    }
                }
            }.onReceive(gamePadManager!.$lastElementPressed) { element in
                guard let mapping = currentMapping,
                      let element else { return }
                gameCommandToElementName[mapping] = element.localizedName!
                currentMapping = nil
                print("Button \(element.localizedName!  ) set for \(mapping)")
            }
        }
    }
}

#Preview {
    SettingsView(hide: {}, gamePadManager: nil)
}

import Combine
