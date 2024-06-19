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

class GameViewController: UIViewController {
    
    var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(fileNamed: "GameScene")
        scene!.size = view.bounds.size
        scene!.scaleMode = .aspectFill
        
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
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
