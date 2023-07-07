//
//  GameViewController.swift
//  TimberMan
//
//  Created by Arthur Dos Reis on 07/07/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let minhaView:SKView = SKView(frame: self.view.frame)
        let minhaCena:GameScene = GameScene(size: minhaView.frame.size)
        self.view = minhaView
        minhaView.contentMode = .scaleAspectFill
        minhaView.presentScene(minhaCena)
        minhaView.ignoresSiblingOrder = false
        minhaView.showsFPS = true
        minhaView.showsPhysics = true
        minhaView.showsNodeCount = true
        
        
    }
}
