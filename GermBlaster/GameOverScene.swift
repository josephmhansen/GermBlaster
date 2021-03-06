//
//  GameOverScene.swift
//  SpacegameReloaded
//
//  Created by Joseph Hansen on 1/24/17.
//  Copyright © 2017 Training. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    var score: Int = 0
    
    var scoreLabel:SKLabelNode!
    var newGameButtonNode: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        scoreLabel.text = "\(score)"
        
        newGameButtonNode = self.childNode(withName: "mainMenuButton") as! SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "MainMenuButton")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let node = self.nodes(at: location)
            
            if node[0].name == "mainMenuButton" {
                let transition = SKTransition.flipVertical(withDuration: 0.8)
                let mainMenuScene = SKScene(fileNamed: "MenuScene") as! MenuScene
                //let mainMenuScene = MenuScene(size: self.size)
                self.view!.presentScene(mainMenuScene, transition: transition)
            }
        }
    }

}
