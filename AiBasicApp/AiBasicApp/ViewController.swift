

import UIKit
import PromiseKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var buttonsView: ButtonsViews!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var tryButton: UIButton!
    @IBOutlet weak var speechLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    let sceneView = ARSCNView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))

    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/newBox.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        
        super.viewDidLoad()
     
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK : Create a new A.I. request by text
    func newRequest(_ text: String) {
        
        //configure AI Request
        let aiRequest = AIRequest(query: text, lang: "en")
        let aiService = AIService(aiRequest)
        
        //Promise block
        firstly{
            removePreviusSearch(text)
            }.then {(finished) -> Promise<AI> in
                aiService.getAi()
            }.then {(ai) -> Void in
                self.updateResults(ai)
            }.catch { (error) in
                //catch error
        }

    }
    
    // MARK : Remove previus search
    func removePreviusSearch(_ newText: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            UIView.animate(withDuration: 0.5, animations:{
                self.topLabel.alpha = 0
                self.mainText.alpha = 0
                self.resultsView.alpha = 0
                self.textField.text = ""
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.5) {
                    self.topLabel.alpha = 1
                    self.mainText.alpha = 1
                }
                fulfill(finished)
                self.topLabel.text = "user says".uppercased()
                self.mainText.text = newText
                self.setLabel(self.speechLabel)
            })
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
    
    // MARK : Try button action
    @IBAction func tryButtonAction(_ sender: UIButton) {
        if textField.text! != "" {
            newRequest(textField.text!)
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
    
    // MARK : update results with the AI data
    func updateResults(_ ai: AI) {
        DispatchQueue.main.async {
            self.setLabel(self.speechLabel, value: ai.intent.speech)
            
            if ai.intent.dates != nil  && ai.intent.dates!.count > 0 {
                var dateString = ""
                for (index, date) in ai.intent.dates!.enumerated() {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateString = dateString + dateFormatter.string(from: date)
                    dateString = index != ai.intent.dates!.count - 1 ? dateString + ", " : dateString
                }
            }

            UIView.animate(withDuration: 0.5) {
                self.resultsView.alpha = 1
            }
        }
    }
    
    // MARK : Setup initial state of view
//    func setInitalState() {
//        //hide items
//        headerView.alpha = 0
//        headerView.alpha = 0
//        mainView.alpha = 0
//        resultsView.alpha = 0
//
//        //setup search bar
//        textField.layer.borderColor = UIColor.grey500.cgColor
//        textField.layer.borderWidth = 1.0
//        textField.layer.cornerRadius = 5
//        textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
//
//        //setup text
//        topLabel.text = "A.I. Tester".uppercased()
//        mainText.text = "Hey there,\nType a question or pick one from the list above."
//
//        //disable try now button
//        tryButton.isEnabled = false
//
//        //setup buttonsView
//        buttonsView.addAction { text in
//            self.newRequest(text)
//        }
//
//        //show with animation
//        UIView.animate(withDuration: 0.5, animations:{
//            self.headerView.alpha = 1
//
//        }, completion: { (finished: Bool) in
//            UIView.animate(withDuration: 0.5) {
//                self.mainView.alpha = 1
//            }
//        })
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
}

