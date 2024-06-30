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
    @ObservedObject var gamePadManager: GamePadManager
    @State private var curCommand: GameCommand? = nil
    @State private var currentAppState: GameState = .playing
    let hide: () -> Void
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
                        curCommand = command
                    }) {
                        HStack {
                            if let commandName = gamePadManager.gameCommandToElementName[command],
                               let sfSymbolName = gamePadManager.elementNameToSymbolName[commandName  ?? "exclamationmark.octagon.fill"] {
                                Image(systemName: sfSymbolName)
                            }
                            Text((gamePadManager.gameCommandToElementName[command] ?? "Test") ?? "Test2")
                        }
                    }
                }
            }.onReceive(gamePadManager.$lastElementPressed) { str in
                guard let command = curCommand,
                      let str else { return }
                gamePadManager.gameCommandToElementName[command] = str
                curCommand = nil
                print("Updated \(command.rawValue) to \(str)")
            }
        }
    }
}

#Preview {
    SettingsView(gamePadManager: GamePadManager(game: Swashteroids(scene: GameScene(),
                                                                   alertPresenter: MockAlertPresenter()),
                                                size: CGSize(width: 100, height: 100)),
                 hide: {})
}

import Combine
