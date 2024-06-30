//
//  SettingsView.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/26/24.
//

import SwiftUI

enum GameState: String, CaseIterable {
    case start = "Start Screen"
    case infoButtons = "Buttons Information Screen"
    case infoNoButtons = "No Buttons Information Screen"
    case playing = "Playing Screen"
    case gameOver = "Game Over Screen"
    var commandsPerScreen: [GameCommand] {
        switch self {
            case .start:
                return [.continue]
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
    @ObservedObject var gamePadManager: GamePadInputManager
    @State private var curCommand: GameCommand? = nil
    @State private var currentAppState: GameState = .playing
    @State private var showAlert = false
    let hide: () -> Void
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    // Save to UserDefaults
                    let defaults = UserDefaults.standard
                    let dictionary = gamePadManager.gameCommandToElementName.mapKeys { $0.rawValue }
                    defaults.set(dictionary, forKey: "GameCommandDict")
                    hide()
                }.padding(0)
                 .padding(.top, 20)
                 .padding(.trailing, 20)
                 .disabled(gamePadManager.gameCommandToElementName.contains { $0.value == nil })
            }
            Text("Settings")
                    .padding(0)
                    .font(.title)
            HStack {
                Text(gamePadManager.gameCommandToElementName.contains { $0.value == nil }
                     ? "Tap a button to assign a function to it. "
                     : "Tap a button to assign a function to it.")
                        .padding(0)
                        .font(.subheadline)
                Text(gamePadManager.gameCommandToElementName.contains { $0.value == nil }
                     ? "All values on all screens must be set."
                     : "")
                        .padding(0)
                        .font(.subheadline)
                        .foregroundColor(.red)
            }
            Picker("Swashteroids State", selection: $currentAppState) {
                ForEach(GameState.allCases, id: \.self) { state in
                    Text(state.rawValue).tag(state)
                }
            }.padding(0)
            List(currentAppState.commandsPerScreen, id: \.self) { command in
                Button(action: {
                    curCommand = command
                    showAlert = true
                }, label: {
                    HStack {
                        Text(command.rawValue)
                        Spacer()
                        if let elementName = gamePadManager.gameCommandToElementName[command],
                           let sfSymbolName = gamePadManager.elementNameToSymbolName[
                               elementName ?? "exclamationmark.octagon.fill"
                               ] {
                            Image(systemName: sfSymbolName)
                        } else {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .foregroundColor(.red)
                        }
                        Text((gamePadManager.gameCommandToElementName[command] ?? "Not Set") ?? "Not Set")
                    }
                })
            }
            HStack {
                Button("Reset to Previous") {
                    gamePadManager.gameCommandToElementName = gamePadManager.loadSettings()
                }
                Spacer()
                Button("Reset to Defaults") {
                    gamePadManager.gameCommandToElementName = GamePadInputManager.defaultMappings
                }
            }.padding()
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Assign Function"),
                message: Text("Press a button on your game controller to assign to '\(curCommand?.rawValue ?? "Test")'"),
                dismissButton: .cancel(Text("Cancel"))
            )
        }.onReceive(gamePadManager.$lastElementPressed) { str in
            guard let command = curCommand,
                  let str = str else { return }
            // Iterate over the dictionary and nil out the previous place where str was used
            for (key, value) in gamePadManager.gameCommandToElementName {
                if value == str {
                    gamePadManager.gameCommandToElementName[key] = nil_string
                }
            }
            // Assign the new str to the current command
            gamePadManager.gameCommandToElementName[command] = str
            curCommand = nil
            showAlert = false
            print("Updated \(command.rawValue) to \(str)")
        }
    }
}

public let nil_string: String? = nil
//#Preview {
//    SettingsView(gamePadManager: GamePadInputManager(game: Swashteroids(scene: GameScene(),
//                                                                   alertPresenter: MockAlertPresenter()),
//                                                size: CGSize(width: 100, height: 100)),
//                 hide: {})
//}
