//
//  ViewController.swift
//  interfaceMock
//
//  Created by matt skeins on 6/14/19.
//  Copyright © 2019 matt-skeins-buddy. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ApiAi

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var chatMessage: UITextField!
    @IBOutlet weak var responseLabel: UILabel!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/newBox.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let configuration = AIDefaultConfiguration()
        configuration.clientAccessToken = "ecc76e9e-3558-4898-bae2-fe0992538211-273dd5df"
        
        let apiai = ApiAI.shared()
        apiai?.configuration = configuration
        
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        let text = chatMessage.text!
        //func(text)
        responseLabel.textColor = UIColor.white
        responseLabel.text = text
        
        chatMessage.endEditing(true)
        print(text)
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        // 1
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//        // 2
//        let width = CGFloat(planeAnchor.extent.x)
//        let height = CGFloat(planeAnchor.extent.z)
//        let plane = SCNPlane(width: width, height: height)
//
//        // 3
//        plane.materials.first?.diffuse.contents = UIColor.blue
//
//        // 4
//        let planeNode = SCNNode(geometry: plane)
//
//        // 5
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
//        planeNode.position = SCNVector3(x,y,z)
//        planeNode.eulerAngles.x = -.pi / 2
//
//        // 6
//        node.addChildNode(planeNode)
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
