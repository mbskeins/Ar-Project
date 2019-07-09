//
//  ViewController.swift
//  ArMonster
//
//  Created by matt skeins on 6/28/19.
//  Copyright © 2019 matt-skeins-buddy. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PromiseKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mainView: UIView!
    //@IBOutlet weak var buttonsView: ButtonsViews!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var tryButton: UIButton!
    @IBOutlet weak var speechLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var messageText: UITextField!
    
    @IBAction func sendPressed(_ sender: Any) {
        newRequest(messageText.text!)
    }

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        setInitalState()
        
   

    }
    
    func speakText(say messageResponse : String){
        
        let voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
        let myUtterance = AVSpeechUtterance(string: messageResponse)
        let synth = AVSpeechSynthesizer()
        myUtterance.voice = voice
        synth.speak(myUtterance)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func newRequest(_ text: String) {
        
        //configure AI Request
        let aiRequest = AIRequest(query: text, lang: "en")
        let aiService = AIService(aiRequest)
        
        //Promise block
        firstly{
            removePreviousSearch(text)
            }.then {(finished) -> Promise<AI> in
                aiService.getAi()
            }.then {(ai) -> Void in
                self.updateResults(ai)
            }.catch { (error) in
                //catch error
        }
        
    }
    
    func updateResults(_ ai: AI) {
        DispatchQueue.main.async {
            self.speakText(say: ai.intent.speech!)
            //self.setLabel(self.speechLabel, value: ai.intent.speech)
            
            if ai.intent.dates != nil  && ai.intent.dates!.count > 0 {
                var dateString = ""
                for (index, date) in ai.intent.dates!.enumerated() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateString = dateString + dateFormatter.string(from: date)
                    dateString = index != ai.intent.dates!.count - 1 ? dateString + ", " : dateString
                }
            }
            
        }
    }
    // MARK : Detect textfield changes
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text != "" {
            tryButton.isEnabled = true
        } else {
            tryButton.isEnabled = false
        }
    }
    
    // MARK : Set label disable / enable
    func setLabel(_ label: UILabel, value: String? = nil) {
        if value != nil && value != "" {
            label.text = value
            label.alpha = 1
        } else {
            label.text = "none"
            label.alpha = 0.2
        }
    }
    
    // MARK : Remove previus search
    func removePreviousSearch(_ newText: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            UIView.animate(withDuration: 0.5, animations:{
//                self.topLabel.alpha = 0
//                self.mainText.alpha = 0
//                self.resultsView.alpha = 0
//                self.textField.text = ""
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.5) {
//                    self.topLabel.alpha = 1
//                    self.mainText.alpha = 1
                }
                fulfill(finished)
                print(newText)
//                self.topLabel.text = "user says".uppercased()
//                self.mainText.text = newText
//                self.setLabel(self.speechLabel)
            })
        }
    }
    
    // MARK : Setup initial state of view
    func setInitalState() {
        //
    }
    
    

    
}
