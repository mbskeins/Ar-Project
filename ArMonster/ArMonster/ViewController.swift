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
import SVProgressHUD
import ChameleonFramework

class policyHolder {
    var name : String
    var policyNumber : String
    var annualPremium : String
    
    init(){
        name = ""
        policyNumber = ""
        annualPremium = ""
    }
    
    init(name : String, policy : String, premium : String){
        self.name = name
        self.policyNumber = policy
        self.annualPremium = premium
    }
    
    func printAllValues(){
        print(name)
        print(policyNumber)
        print(annualPremium)
    }
    
}

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
    let synth = AVSpeechSynthesizer()
    var imageConfiguration: ARImageTrackingConfiguration?

    var recognizedImageContent = [ String : policyHolder ]()

    
    @IBOutlet weak var sendButton: UIButton!
    var modelPlaced = false
    var center : CGPoint!
    let arrow = SCNScene(named: "art.scnassets/arrow.scn")!.rootNode
    let idleScene = SCNScene(named: "art.scnassets/talkingFixed.dae")!
    var positions = [SCNVector3]()
    
    @IBAction func clearPressed(_ sender: Any) {
        idleScene.rootNode.enumerateChildNodes { (node, stop) in
            if node.name == "removeWindow" {
                node.removeFromParentNode()
            }
        }
    }
    @IBAction func sendPressed(_ sender: Any) {
       SVProgressHUD.show()
        idleScene.rootNode.enumerateChildNodes { (node, stop) in
            if node.name == "remove" {
                node.removeFromParentNode()
            }
        }
        newRequest(messageText.text!)
    }

    var animations = [String: CAAnimation]()
    var idle:Bool = true
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        center = view.center
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let hitTest = sceneView.hitTest(center, types: .featurePoint)
        
        let result = hitTest.last
        
        guard let transform = result?.worldTransform else {return}
        
        let thirdColumn = transform.columns.3
        
        let position = SCNVector3Make(thirdColumn.x, thirdColumn.y, thirdColumn.z)
        
        positions.append(position)
        
        let lastTenPositions = positions.suffix(10)
        
        arrow.position = getAveragePosition(from: lastTenPositions)
        
       // let anchorPosition = Idl.transforms.columns.3
        //let cameraPosition = sceneView.session.currentFrame
        // here’s a line connecting the two points, which might be useful for other things
       // let cameraToAnchor = cameraPosition - anchorPosition
        // and here’s just the scalar distance
        //let distance = length(cameraToAnchor)

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let image = imageAnchor.referenceImage
        print(image.name)
        if let imageName = image.name {
            say(what: recognizedImageContent[imageName]!.name)
            let panelNode = createPolicyWindow(imageName: imageName)
            panelNode.name = "removeWindow"
            idleScene.rootNode.addChildNode(panelNode)
            say(what: "Hello \(recognizedImageContent[imageName]!.name) it looks like your premium is: \(recognizedImageContent[imageName]!.annualPremium)")
        }
        
    }
    
    func createPolicyWindow(imageName : String) -> SCNNode {
        
        let policyHolder = recognizedImageContent[imageName]
        var windowPane = SCNBox(width: 150, height: 150, length: 3, chamferRadius: 50)
    
        windowPane.firstMaterial?.diffuse.contents = UIColor.red
        var windowNode = SCNNode(geometry: windowPane)
        
        
        windowNode.geometry?.firstMaterial?.diffuse.contents = UIColor.flatRed()
        let policyHolderName = SCNText(string: "Policy Holder: \(policyHolder!.name)", extrusionDepth: 1)
        let policyHolderTextNode = SCNNode(geometry: policyHolderName)
        policyHolderName.font = UIFont(name: "Helvetica", size: 10.0)
        policyHolderTextNode.position.z = 3
        policyHolderTextNode.position.x = -60
        policyHolderTextNode.position.y = 30
        
        let policyNo = SCNText(string: "Policy Number: \(policyHolder!.policyNumber)", extrusionDepth: 1)
        let policyNoTextNode = SCNNode(geometry: policyNo)
        policyNo.font = UIFont(name: "Helvetica", size: 10.0)
        policyNoTextNode.position.z = 3
        policyNoTextNode.position.x = -60
        policyNoTextNode.position.y = 0
        
        
        let annualPrem = SCNText(string: "Annual Premium: \(policyHolder!.annualPremium)", extrusionDepth: 1)
        let annualPremNode = SCNNode(geometry: annualPrem)
        annualPrem.font = UIFont(name: "Helvetica", size: 10.0)
        annualPremNode.position.z = 3
        annualPremNode.position.x = -60
        annualPremNode.position.y = -30
        
        policyHolderName.firstMaterial?.diffuse.contents = UIColor.flatWhite()
        policyNo.firstMaterial?.diffuse.contents = UIColor.flatWhite()
        annualPrem.firstMaterial?.diffuse.contents = UIColor.flatWhite()
        
        windowNode.addChildNode(policyHolderTextNode)
        windowNode.addChildNode(policyNoTextNode)
        windowNode.addChildNode(annualPremNode  )
        windowNode.position.x += 120
        windowNode.position.y += idleScene.rootNode.position.y + 50
        
        return windowNode
    
    }
    
    func say(what description: String){
        synth.stopSpeaking(at: .immediate)
        let content = AVSpeechUtterance(string: description)
        synth.speak(content)
    }
    
    
    
    func getAveragePosition(from positions : ArraySlice<SCNVector3>) -> SCNVector3 {
        
        var averageX : Float = 0
        var averageY : Float = 0
        var averageZ : Float = 0
        
        for position in positions {
            
            averageX += position.x
            averageY += position.y
            averageZ += position.z
        }
        let count = Float(positions.count)
        return SCNVector3Make(averageX / count, averageY / count, averageZ / count)
    }
    
    override func viewDidLoad() {
        //recognizedImageContent
        let nickPappasPolicy = policyHolder(name: "Nick Pappas", policy: "123456789", premium: "$984")
        let mattSkeinsPolicy = policyHolder(name: "Matt Skeins", policy: "65943827", premium: "$661")
        let brandyTroxellPolicy = policyHolder(name: "Brandy Troxell", policy: "2187023", premium: "$749")

        
        recognizedImageContent["license"] = nickPappasPolicy
        recognizedImageContent["license2"] = mattSkeinsPolicy
        recognizedImageContent["license3"] = brandyTroxellPolicy

        
        idleScene.rootNode.scale = SCNVector3(0.006, 0.006, 0.006)
        sendButton.layer.cornerRadius = 7
        
        
        let directionalLight = SCNLight()
        directionalLight.type = .directional

        idleScene.rootNode.light = directionalLight
        
        super.viewDidLoad()
        sceneView.delegate = self
        center = view.center
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.rootNode.addChildNode(arrow)
        
        // Load the DAE animations
        //loadAnimations()
    }
    


    
    func loadAnimations () {
        // Load the character in the idle animation
        
        // This node will be parent of all the animation models
        let node = SCNNode()
        
        // Add all the child nodes to the parent node
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        // Set up some properties
        node.position = SCNVector3(0, -10, -20)
        node.scale = SCNVector3(0.08, 0.08, 0.08)
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(node)
        
        // Load all the DAE animations
        loadAnimation(withKey: "dancing", sceneName: "art.scnassets/fightFixed", animationIdentifier: "fightAnim")
    }
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            // The animation will only play once
            animationObject.repeatCount = 1
            // To create smooth transitions between animations
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            
            // Store the animation for later use
            animations[withKey] = animationObject
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if modelPlaced == false {
            guard let angle = sceneView.session.currentFrame?.camera.eulerAngles.y else { return }
            idleScene.rootNode.position = arrow.position
            idleScene.rootNode.eulerAngles.y = angle
            modelPlaced = true
            sceneView.scene.rootNode.addChildNode(idleScene.rootNode)
            arrow.removeFromParentNode()
        }
//        let location = touches.first!.location(in: sceneView)
//
//        // Let's test if a 3D Object was touch
//        var hitTestOptions = [SCNHitTestOption: Any]()
//        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
//
//        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
//
//        if hitResults.first != nil {
//            if(idle) {
//                playAnimation(key: "dancing")
//            } else {
//                stopAnimation(key: "dancing")
//            }
//            idle = !idle
//            return
//        }
    }
    func playAnimation(key: String) {
        // Add the animation to start playing it right away
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        // Stop the animation with a smooth transition
        idleScene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Images", bundle: nil)
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
    }
    

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            print(keyboardHeight)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    func speakText(say messageResponse : String){
        let textGeometry = SCNText(string: messageResponse, extrusionDepth: 1)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.flatRed()
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.75, 1, 0.75)
        var modelPos = idleScene.rootNode.position
        modelPos.y += 175
        modelPos.x -= 125
        textNode.position = modelPos
        textNode.name = "remove"
        idleScene.rootNode.addChildNode(textNode)
        
        let voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
        let myUtterance = AVSpeechUtterance(string: messageResponse)
        print(myUtterance)

        myUtterance.voice = voice
        //  need to make assignment from distance to 3d object
        myUtterance.volume = 100
        synth.speak(myUtterance)
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
         SVProgressHUD.dismiss()
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



