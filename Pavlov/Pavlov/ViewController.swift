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
    private var started = false

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
                self.started = true
                self.spinner.startAnimating()
                self.thread = Thread(block: { self.startRecording() })
                self.thread?.start()
            } else {
                self.navigationController?.popViewController(animated: true)
                let alertController = UIAlertController(title: "Pavlov", message:
                    "Microphone or recording capabilities are currently unavailable. Please check your settings.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.amountLabel.text = "$" + String(format: "%.2f", Model.INSTANCE.getAmount())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if thread != nil && (thread?.isExecuting)! {
            thread?.cancel()
        }
        
        if started && Model.INSTANCE.getAmount() > 0 {
            //postPayments()
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
        
        recognitionRequest?.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!, resultHandler: { (result, error) in
            
            if result != nil {
                
                let recognizedText = result?.bestTranscription.formattedString
                
                if recognizedText!.contains("sorry") || recognizedText!.contains("Sorry") {
                    OperationQueue.main.addOperation {
                        self.totalLabel.textColor = UIColor.black
                        self.amountLabel.textColor = UIColor.black
                        self.view.backgroundColor = UIColor.white
                    }
                }
                
                if recognizedText!.characters.count >= 60 {
                    self.analyzeText(recognizedText!)
                    self.audioEngine.stop()
                    recognitionTask?.finish()
                    inputNode.removeTap(onBus: 0)
                    self.startRecording()
                }
            }
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
    }
    
    func analyzeText(_ s: String) {
        let url = URL(string: "http://localhost:9090/pavlov")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["text":s], options: .prettyPrinted)
        } catch {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error)
                return
            }
            guard let data = data else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                
                let isGood = json["isGood"] as! Bool
                if !isGood {
                    Model.INSTANCE.incrementAmount()
                    OperationQueue.main.addOperation {
                        self.amountLabel.text = "$" + String(format: "%.2f", Model.INSTANCE.getAmount())
                        self.textField.text = s
                        self.view.backgroundColor = UIColor(red: 225 / 255, green: 65 / 255, blue: 61 / 255, alpha: 1)
                        self.totalLabel.textColor = UIColor.white
                        self.amountLabel.textColor = UIColor.white
                    }
                }
            } catch { }
        }
        task.resume()
    }
    
    func postPayments() {
        let url = URL(string: "http://localhost:9090/pay")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: ["account":Model.INSTANCE.familyAccount, "amount":Model.INSTANCE.amount], options: .prettyPrinted)
        } catch {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error)
                return
            }
            guard let data = data else {
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                
                let individualCost = json["cost"] as! Double
                let alertController = UIAlertController(title: "Pavlov", message:
                    "Total: \(Model.INSTANCE.amount)\nIndividual Share: \(individualCost)\nEach participant has paid their share to the group account.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                Model.INSTANCE.amount = 0.00
            } catch { }
        }
        task.resume()
    }
}
