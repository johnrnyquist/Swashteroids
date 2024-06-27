//
//  SettingsView.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/26/24.
//

import SwiftUI

struct SettingsView: View {
    var onTap: () -> Void

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap()
                }
            Text("Hello, World!")
        }
    }
}
#Preview {
    SettingsView(onTap: {})
}
