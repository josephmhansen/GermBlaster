//
//  MenuScene.swift
//  SpacegameReloaded
//
//  Created by Joseph Hansen on 1/21/17.
//  Copyright © 2017 Training. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var background: SKEmitterNode?
    var newGameButtonNode: SKSpriteNode?
    var gameModeButtonNode: SKSpriteNode?
    var modeLabelNode: SKLabelNode?
    
    
    
    
    
    override func didMove(to view: SKView) {
        
        guard let background = self.childNode(withName: "background") as? SKEmitterNode else {return}
        background.advanceSimulationTime(7)
        
        guard (self.childNode(withName: "newGameButton") as? SKSpriteNode) != nil else {return}
        guard (self.childNode(withName: "gameModeButton") as? SKSpriteNode) != nil else {return}
        guard let modeLabelNode = self.childNode(withName: "modeLabel") as? SKLabelNode else {return}
        
        // newGameButtonNode.texture = SKTexture(imageNamed: "NewGame")
        // gameModeButtonNode.texture = SKTexture(imageNamed: "MODE")
        
        
        
       
        //FIXXX THIS
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "difficult")  {
            modeLabelNode.text = "Difficult"
        } else {
            modeLabelNode.text = "Normal"
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton" {
                let transition = SKTransition.flipVertical(withDuration: 0.7)
                let gameScene = GameScene(size: self.size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "gameModeButton" {
                changeMode()
                print("Mode Button Tapped")
            } else if nodesArray.first?.name == "exitGameButton" {
                print("Exit button tapped")
            }
        }
    }
    
    func changeMode() {
        let userDefaults = UserDefaults.standard
        guard let modeLabelNode = self.childNode(withName: "modeLabel") as? SKLabelNode else {return}
        if modeLabelNode.text == "Normal" {
            modeLabelNode.text = "Difficult"
            userDefaults.set(true, forKey: "difficult")
        } else {
            modeLabelNode.text = "Normal"
            userDefaults.set(false, forKey: "difficult")
        }
        userDefaults.synchronize()
    }

}
