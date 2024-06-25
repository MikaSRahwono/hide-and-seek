//
//  GameViewModel.swift
//  goleki
//
//  Created by Johan Sianipar on 25/06/24.
//

import UIKit
import GameKit

class GameViewModel: NSObject, ObservableObject {
    var player1Position = CGPoint(x: 100, y: 100)
    var player2Position = CGPoint(x: 200, y: 200)
    var showMatchmaker = false
    var showError = false
    var errorMessage = ""
    
    var positionUpdateHandler: (() -> Void)?
    weak var viewController: UIViewController?
    
    private var localPlayer = GKLocalPlayer.local
    var match: GKMatch?
    var matchmakerViewController: GKMatchmakerViewController?
    
    enum Direction {
        case up, down, left, right
    }
    
    override init() {
        super.init()
        GKLocalPlayer.local.register(self)
    }
    
    func setupMultiplayer() {
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            if let viewController = viewController {
                self?.present(viewController: viewController)
            } else if self?.localPlayer.isAuthenticated == true {
                self?.startMatchmaking()
            } else {
                self?.showErrorMessage("Authentication failed. Please check your Game Center settings.")
            }
        }
    }
    
    func startMatchmaking() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        matchmakerViewController = GKMatchmakerViewController(matchRequest: request)
        matchmakerViewController?.matchmakerDelegate = self
        
        DispatchQueue.main.async {
            if let matchmakerViewController = self.matchmakerViewController {
                self.present(viewController: matchmakerViewController)
            }
        }
    }
    
    func movePlayer1(direction: Direction) {
        let step: CGFloat = 10
        switch direction {
        case .up:
            player1Position.y -= step
        case .down:
            player1Position.y += step
        case .left:
            player1Position.x -= step
        case .right:
            player1Position.x += step
        }
        
        sendData(position: player1Position)
    }
    
    func sendData(position: CGPoint) {
        var position = position
        let data = Data(bytes: &position, count: MemoryLayout<CGPoint>.size)
        
        do {
            try match?.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            showErrorMessage("Failed to send data: \(error.localizedDescription)")
        }
    }
    
    func receiveData(_ data: Data) {
        var position = CGPoint()
        data.withUnsafeBytes { buffer in
            let pointer = buffer.bindMemory(to: CGPoint.self)
            position = pointer.baseAddress!.pointee
        }
        
        DispatchQueue.main.async {
            self.player2Position = position
            self.positionUpdateHandler?()
        }
    }
    
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func present(viewController: UIViewController) {
        self.viewController?.present(viewController, animated: true, completion: nil)
    }
}

extension GameViewModel: GKMatchmakerViewControllerDelegate {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true, completion: nil)
        showMatchmaker = false
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        showErrorMessage("Matchmaking failed: \(error.localizedDescription)")
        viewController.dismiss(animated: true, completion: nil)
        showMatchmaker = false
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        self.match = match
        match.delegate = self
        viewController.dismiss(animated: true, completion: nil)
        showMatchmaker = false
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didReceiveAcceptFromRemotePlayer player: GKPlayer) {lee f ,,j
        print("Player \(player.displayName) accepted the match")
    }
}

extension GameViewModel: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        receiveData(data)
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            print("Player \(player.displayName) connected")
        case .disconnected:
            showErrorMessage("Player \(player.displayName) disconnected")
        default:
            break
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        showErrorMessage("Match failed with error: \(error?.localizedDescription ?? "unknown error")")
    }
}

extension GameViewModel: GKLocalPlayerListener {
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        let matchmaker = GKMatchmaker.shared()
        matchmaker.match(for: invite) { match, error in
            if let error = error {
                self.showErrorMessage("Failed to accept invite: \(error.localizedDescription)")
                return
            }
            self.match = match
            self.match?.delegate = self
        }
    }
}
