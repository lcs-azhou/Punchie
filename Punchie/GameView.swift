//
//  GameView.swift
//  Punchie
//
//  Created by Ansheng Zhou on 2025-02-13.
//

import SwiftUI

// Game View - Manages levels and score tracking
struct GameView: View {
    @State private var isPunchDetected = false
    @State private var score = 0
    @State private var level = 1

    let levelThreshold = 5 // Each level requires an additional 5 points

    var body: some View {
        ZStack {
            
            CameraView(isPunchDetected: $isPunchDetected, score: $score, level: $level)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading) {
                Text("Level: \(level)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                Text("Score: \(score)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                
                Text(isPunchDetected ? "🥊 Punch detected!" : "Throw a punch!")
                    .font(.title)
                    .foregroundColor(isPunchDetected ? .green : .gray)
                    .padding()
            }
        }
    }
}
