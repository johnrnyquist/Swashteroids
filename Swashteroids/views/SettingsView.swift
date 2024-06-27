//
//  SettingsView.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/26/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var buttonMappings: [Functionality: GameControllerInput] = [:] // This should be loaded from persistent storage
    @State private var currentMapping: Functionality? = nil
    @State private var currentAppState: SwashteroidsState = .playing // Replace with the actual current AppState
    var body: some View {
        VStack {
            Text("Settings")
                    .font(.title)
                    .padding()
            Picker("Swashteroids State", selection: $currentAppState) {
                List(currentAppState.functionalities, id: \.self) { functionality in
                    HStack {
                        Text(functionality.rawValue)
                        Spacer()
                        Button(action: {
                            currentMapping = functionality
                        }) {
                            Text(buttonMappings[functionality]?.description ?? "Not Set")
                        }
                    }
                }
                        .onReceive(GameController.shared.$lastButtonPressed) { button in
                            guard let mapping = currentMapping else { return }
                            buttonMappings[mapping] = button
                            currentMapping = nil
                            // Save buttonMappings to persistent storage here
                        }
            }
        }
    }
}

#Preview {
    SettingsView()
}

import Combine

class GameController: ObservableObject {
    static let shared = GameController()
    @Published var lastButtonPressed: GameControllerInput?

    private init() {}
}
