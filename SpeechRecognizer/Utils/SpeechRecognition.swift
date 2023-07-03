//
//  SpeechRecognition.swift
//  SpeechRecognizer
//
//  Created by admin on 02.07.2023.
//

import SwiftUI
import Combine
import Speech
import AVFoundation

final class SpeechRecognition: ObservableObject {
    
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru_RU"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @Published var randomNumber = ""
    @Published var speechText = ""
    
    private var cancellable: AnyCancellable?
    private var timerCancellable: AnyCancellable?
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .interruptSpokenAudioAndMixWithOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
                guard let result = result else { return }
                let transcript = result.bestTranscription.formattedString
                
                self.addNumber()

                print(transcript)
                self.speechText = transcript
            })
        } catch let error {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }
    
    private func addNumber() {
        self.timerCancellable = Timer.publish(every: 1.0, tolerance: 0.5, on: .main, in: .common)
            .autoconnect()
            .map { _ in
                let randomNumber = arc4random_uniform(100)
                return " \(randomNumber)"
            }
            .assign(to: \.randomNumber, on: self)
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest = nil
        recognitionTask = nil
    }
}
