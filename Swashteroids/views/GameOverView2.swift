//
//  GameOverView2.swift
//  Swashteroids
//
//  Created by John Nyquist on 1/13/24.
//

import SwiftUI

struct GameOverView2: View {
    let hitPercentage = 0
    var body: some View {
        VStack(alignment: .center, spacing: 0) { // Add the spacing parameter here
            Text("Game Over")
                .font(.custom("Badloc ICG", size: 75))

            Text("Hit Percentage: 0%")
                .font(.custom("Futura-Medium", size: 24))

            Image("swash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.4)
                .scaleEffect(0.5)
        }
            .background(.black)
            .foregroundColor(.white)
    }
}

// Preview
struct GameOverView2_Previews: PreviewProvider {
    static var previews: some View {
        GameOverView2().previewLayout(.sizeThatFits)
    }
}
