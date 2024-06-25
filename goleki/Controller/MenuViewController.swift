//
//  MenuViewController.swift
//  goleki
//
//  Created by Muhammad Yusuf on 24/06/24.
//

import UIKit
import GameKit

class MenuViewController: UIViewController {

    @IBOutlet weak var buttonMultiplayer: UIButton!
    
    private var gameCenterHelper: GameCenterHelper!
    var viewModel = GameViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonMultiplayer.isEnabled = false
        buttonMultiplayer.layer.cornerRadius = 10
        viewModel.viewController = self
                viewModel.setupMultiplayer()
//        gameCenterHelper = GameCenterHelper()
//        gameCenterHelper.delegate = self
//        gameCenterHelper.authenticatePlayer()
    }

    @IBAction func buttonMultiplayerPressed() {
        gameCenterHelper.presentMatchmaker()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? GameViewController,
              let match = sender as? GKMatch else { return }
        
        vc.match = match
    }
}

extension MenuViewController: GameCenterHelperDelegate {
    func didChangeAuthStatus(isAuthenticated: Bool) {
        buttonMultiplayer.isEnabled = isAuthenticated
    }
    
    func presentGameCenterAuth(viewController: UIViewController?) {
        guard let vc = viewController else {return}
        self.present(vc, animated: true)
    }
    
    func presentMatchmaking(viewController: UIViewController?) {
        guard let vc = viewController else {return}
        self.present(vc, animated: true)
    }
    
    func presentGame(match: GKMatch) {
        performSegue(withIdentifier: "showGame", sender: match)
    }
}

