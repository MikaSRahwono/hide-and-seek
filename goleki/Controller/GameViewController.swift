//
//  GameViewController.swift
//  goleki
//
//  Created by Mika S Rahwono on 11/06/24.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFAudio
import GameKit

class GameViewController: UIViewController {
    var viewModel = GameViewModel()
    var audioPlayer = AVAudioPlayer()
    var match: GKMatch?
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = {(viewController, error) -> Void in

            if (viewController != nil) {
                self.present(viewController!, animated: true, completion: nil)
            }
            else {
                print((GKLocalPlayer.local.isAuthenticated))
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(fileNamed: "GameScene 2")
        scene!.size = view.bounds.size
        scene!.scaleMode = .aspectFill
        
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
//        viewModel.setupMultiplayer()
        skView.presentScene(scene)
        
        viewModel.viewController = self
                viewModel.setupMultiplayer()
//                viewModel.positionUpdateHandler = { [weak self] in
//                    self?.updatePlayerPositions()
//                }
        
//        authenticateLocalPlayer()
//        skView.showsPhysics = true
        
//        playSaveSound()
    }
    
//    func playSaveSound(){
//        let path = Bundle.main.path(forResource: "backgroundMusic.mp3", ofType: nil)!
//        let url = URL(fileURLWithPath: path)
//
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
//            audioPlayer.prepareToPlay()
//            audioPlayer.numberOfLoops = -1
//            audioPlayer.play()
//            audioPlayer.volume = 0.3
//        } catch {
//            print("couldn't load the file")
//        }
//    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
}
