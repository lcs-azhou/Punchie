//
//  ContentView.swift
//  Punchie
//
//  Created by Ansheng Zhou on 2025-02-12.
//

import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @State private var isPunchDetected = false
    @State private var score = 0
    @State private var level = 1
    
    var body: some View {
        VStack {
            Text("Boxing Game")
                .font(.largeTitle)
                .padding()
            
            ZStack {
                
                GameView()
                
            }
            
            
        }
    }
}





#Preview {
    ContentView()
}
