//
//  ViewController.swift
//  ARVideoKitWithEmojis
//
//  Created by Thinh Luong on 4/1/18.
//  Copyright © 2018 Vantan LLC. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate, RenderARDelegate, RecordARDelegate {

  @IBOutlet var sceneView: ARSKView!
  var recorder: RecordAR?
  
  var recorderButton: UIButton = {
    let button =  UIButton(type: .system)
    button.setTitle("Record", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .white
    button.frame = CGRect(x: 0, y: 0, width: 110, height: 60)
    button.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.90)
    button.layer.cornerRadius = button.bounds.height / 2
    button.tag = 0
    return button
  } ()
  
  var pauseButton: UIButton = {
    let button =  UIButton(type: .system)
    button.setTitle("Pause", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .white
    button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
    button.center = CGPoint(x: UIScreen.main.bounds.width * 0.15, y: UIScreen.main.bounds.height * 0.90)
    button.layer.cornerRadius = button.bounds.height / 2
    button.alpha = 0.3
    button.isEnabled = false
    return button
  } ()
  
  var gifButton: UIButton = {
    let button =  UIButton(type: .system)
    button.setTitle("GIF", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = .white
    button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
    button.center = CGPoint(x: UIScreen.main.bounds.width * 0.85, y: UIScreen.main.bounds.height * 0.90)
    button.layer.cornerRadius = button.bounds.height / 2
    return button
  } ()
  
  @objc func recorderAction(sender: UIButton) {
    if recorder?.status == .readyToRecord {
      recorder?.record()
   
      setButton(sender, title: "Stop", color: .red)
      
      enableButton(pauseButton)
      disableButton(gifButton)
      
    } else if recorder?.status == .recording || recorder?.status == .paused {
      recorder?.stopAndExport()
      
      setButton(sender, title: "Record", color: .black)
      enableButton(gifButton)
      disableButton(pauseButton)
    }
  }
  
  @objc func pauseAction(sender: UIButton) {
    if recorder?.status == .recording {
      recorder?.pause()
      
      setButton(sender, title: "Resume", color: .blue)
    } else if recorder?.status == .paused {
      recorder?.record()
      
      setButton(sender, title: "Pause", color: .black)
    }
  }
  
  @objc func gifAction(sender: UIButton) {
    
  }
  
  private func setButton(_ button: UIButton, title: String, color: UIColor) {
    button.setTitle(title, for: .normal)
    button.setTitleColor(color, for: .normal)
  }
  
  private func disableButton(_ button: UIButton) {
    button.alpha = 0.3
    button.isEnabled = false
  }
  
  private func enableButton(_ button: UIButton) {
    button.alpha = 1.0
    button.isEnabled = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.addSubview(recorderButton)
    view.addSubview(pauseButton)
    view.addSubview(gifButton)
    
    recorderButton.addTarget(self, action: #selector(recorderAction(sender:)), for: .touchUpInside)
    pauseButton.addTarget(self, action: #selector(pauseAction(sender:)), for: .touchUpInside)
    gifButton.addTarget(self, action: #selector(gifAction(sender:)), for: .touchUpInside)
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and node count
    sceneView.showsFPS = true
    sceneView.showsNodeCount = true
    
    // Load the SKScene from 'Scene.sks'
    if let scene = SKScene(fileNamed: "Scene") {
      sceneView.presentScene(scene)
    }
    
    recorder = RecordAR(ARSpriteKit: sceneView)
    recorder?.delegate = self
    recorder?.renderAR = self
    recorder?.onlyRenderWhileRecording = false
    
    
    recorder?.inputViewOrientations = [
      .portrait,
      .landscapeLeft,
      .landscapeRight
    ]
    recorder?.deleteCacheWhenExported = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    // Run the view's session
    sceneView.session.run(configuration)
    
    recorder?.prepare(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
    
    if recorder?.status == .recording {
      recorder?.stopAndExport()
    }
    
    recorder?.onlyRenderWhileRecording = true
    recorder?.prepare(ARWorldTrackingConfiguration())
    
    recorder?.rest()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  // MARK: - ARSKViewDelegate
  
  func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
    // Create and configure a node for the anchor added to the view's session.
    let labelNode = SKLabelNode(text: "👾")
    labelNode.horizontalAlignmentMode = .center
    labelNode.verticalAlignmentMode = .center
    return labelNode;
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
  }
}

//MARK: - ARVideoKit Delegate Methods
extension ViewController {
  func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {
    // Do some image/video processing.
  }
  
  func recorder(didEndRecording path: URL, with noError: Bool) {
    if noError {
      // Do something with the video path.
    }
  }
  
  func recorder(didFailRecording error: Error?, and status: String) {
    // Inform user an error occurred while recording.
  }
  
  func recorder(willEnterBackground status: RecordARStatus) {
    // Use this method to pause or stop video recording. Check [applicationWillResignActive(_:)](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622950-applicationwillresignactive) for more information.
    if status == .recording {
      recorder?.stopAndExport()
    }
  }
}
