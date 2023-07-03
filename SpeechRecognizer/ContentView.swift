//
//  ContentView.swift
//  SpeechRecognizer
//
//  Created by admin on 02.07.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var speechRecognition = SpeechRecognition()
    
    var body: some View {
        VStack {
            HStack {
                Text(speechRecognition.speechText)
                    .padding()
                Text(speechRecognition.randomNumber)
                    .padding()
            }
            Button("Press", action: {
                speechRecognition.stopRecording()
            }).simultaneousGesture(
                LongPressGesture(minimumDuration: 0)
                    .onEnded { _ in
                        speechRecognition.startRecording()
                    })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
