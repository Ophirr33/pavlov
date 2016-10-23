//
//  ViewController.swift
//  Pavlov
//
//  Created by Ceridwen Driskill on 10/22/16.
//  Copyright © 2016 Ceridwen Driskill. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var textField: UITextView!
    
    private var thread: Thread?

    private var latestRecognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isRecordingEnabled = false

            switch authStatus {
            case .authorized:
                isRecordingEnabled = true
                
            case .denied:
                isRecordingEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isRecordingEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isRecordingEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            if isRecordingEnabled {
                self.spinner.startAnimating()
                self.thread = Thread(block: { self.startRecording() })
                self.thread?.start()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (thread?.isExecuting)! {
            thread?.cancel()
        }
    }
    
    func startRecording() {
        
        let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
        speechRecognizer.delegate = self
        
        var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
        var recognitionTask: SFSpeechRecognitionTask?
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard recognitionRequest != nil else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest?.shouldReportPartialResults = false
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!, resultHandler: { (result, error) in
            
            if result != nil {
                
                let recognizedText = result?.bestTranscription.formattedString
                
                if recognizedText!.contains("sorry") || recognizedText!.contains("Sorry") {
                    OperationQueue.main.addOperation {
                        self.view.backgroundColor = UIColor.white
                        self.totalLabel.textColor = UIColor.black
                        self.amountLabel.textColor = UIColor.black
                    }
                }
                if Model.INSTANCE.sendTextForAnalysis(s: recognizedText!) {
                    Model.INSTANCE.incrementAmount()
                    OperationQueue.main.addOperation {
                        self.amountLabel.text = "$" + String(format: "%.2f", Model.INSTANCE.getAmount())
                        self.textField.text = recognizedText
                        self.view.backgroundColor = UIColor.red
                        self.totalLabel.textColor = UIColor.white
                        self.amountLabel.textColor = UIColor.white
                    }
                }
            }
            
            self.audioEngine.stop()
            inputNode.removeTap(onBus: 0)
            self.startRecording()
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        sleep(5)
        self.audioEngine.stop()
        recognitionTask?.finish()
    }
}
