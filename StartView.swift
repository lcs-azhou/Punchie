//
//  StartView.swift
//  Punchie
//
//  Created by Ansheng Zhou on 2025-02-12.
//

import SwiftUI

struct StartView: View {
    @State private var navigateToGame = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Boxing Game")
                    .font(.largeTitle)
                    .padding()

                Text("Throw punches and improve your reflexes!")
                    .font(.title2)
                    .padding()

                Button(action: {
                    navigateToGame = true
                }) {
                    Text("Start Game")
                        .font(.title)
                        .bold()
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding()
                .navigationDestination(isPresented: $navigateToGame) {
                    GameView()
                }
            }
        }
    }
}

#Preview {
    StartView()
}
