//
//  GameScene.swift
//  SpacegameReloaded
//
//  Created by Joseph Hansen on 01/07/2017.
//  Copyright © 2016 Joseph Hansen. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    ///Buttons
    var directionOneButton: SKSpriteNode!
    var directionTwoButton: SKSpriteNode!
    var canonFireButton: SKSpriteNode!
    
    
    //Bubble-like animation for background
    var background:SKEmitterNode!
    //Player
    var player: SKSpriteNode!
    
    //Score Label in top left corner
    var scoreLabel:SKLabelNode!
    
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    //Times the rate that the germs spawn
    var gameTimer:Timer!
    //Array of Germs
    var possibleGerms = ["bacteria1", "bacteria2", "bacteria3", "bacteria4"]
    
    //Categories created to allow the germs to be destroyed by the laser
    let germCategory:UInt32 = 0x1 << 1
    let laserCategory:UInt32 = 0x1 << 0
    
    //stores how many lives remaining user has (indicated by hearts on the top right corner of screen)
    var healthArray: [SKSpriteNode]!
    
    
    // This is similar to viewDidLoad
    override func didMove(to view: SKView) {
        
        loadHealth()
        
        //This creates and adds background emitter to view and sets the z position to be behind everything else
        background = SKEmitterNode(fileNamed: "Background")
        background.position = CGPoint(x: self.frame.midX, y: 0)
        background.advanceSimulationTime(10)
        self.addChild(background)
        background.zPosition = -1
        
        
        //links image to playerNode
        player = SKSpriteNode(imageNamed: "anti_body")
        //sets default position that player is at when game loads
        player.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 120)
        player.size = CGSize(width: 135, height: 135)
        self.addChild(player)
        
        
        
        
        ///Gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 5)
        self.physicsWorld.contactDelegate = self
        
        //Adds score Label
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 150, y: self.frame.size.height - 120)
        scoreLabel.fontName = "GOptima-ExtraBlack"
        scoreLabel.fontSize = 65
        scoreLabel.fontColor = UIColor.white
        score = 0
        self.addChild(scoreLabel)
        
        // The following allows you to easily modify the spawn rate of germs to adjust difficulty for player,
        var timeInterval = 8.0
        
        if UserDefaults.standard.bool(forKey: "difficult") {
            timeInterval = 4.0
        }
        
        //calls addGerm Function based on timeInterval selected from menu screen
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addGerm), userInfo: nil, repeats: true)
        
        
        //Programatically added buttons for testing, Left, Right, and Laser Functions
        directionOneButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        directionOneButton.position = CGPoint(x: self.frame.minX + 100, y: self.frame.minY + 100)
        
        directionTwoButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        directionTwoButton.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.minY + 100)
        
        canonFireButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        canonFireButton.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.minY + 250)
        
        self.addChild(directionOneButton)
        self.addChild(directionTwoButton)
        self.addChild(canonFireButton)
        
        
        
    }
    
    //loads health, and tracks remaining lives throughout gameplay
    func loadHealth() {
        healthArray = [SKSpriteNode]()
        
        for live in 1 ... 4 {
            let liveNode = SKSpriteNode(imageNamed: "health")
            liveNode.size = CGSize(width: 60, height: 60)
            liveNode.position = CGPoint(x: self.frame.size.width - CGFloat(5 - live) * liveNode.size.width , y: self.frame.size.height - 100)
            self.addChild(liveNode)
            healthArray.append(liveNode)
        }
        
        
    }
    
    
    //Adds germ to display at a random x position, selects random germ image from array
    func addGerm () {
        
        possibleGerms = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleGerms) as! [String]
        
        let germ = SKSpriteNode(imageNamed: possibleGerms[0])
        let randomGermPosition = GKRandomDistribution(lowestValue: Int(self.frame.minX + 270), highestValue: Int(self.frame.maxX - 270))
        //allows x axis to be set to random
        let position = CGFloat(randomGermPosition.nextInt())
        
        germ.position = CGPoint(x: position, y: self.frame.maxY + germ.size.height)
        germ.size = CGSize(width: 110, height: 110)
        germ.physicsBody = SKPhysicsBody(rectangleOf: germ.size)
        germ.physicsBody?.isDynamic = true
        germ.physicsBody?.categoryBitMask = germCategory
        germ.physicsBody?.contactTestBitMask = laserCategory
        germ.physicsBody?.collisionBitMask = 0
        
        self.addChild(germ)
        
        let animationDuration:TimeInterval = 18
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -germ.size.height), duration: animationDuration))
        
        
        actionArray.append(SKAction.run {
            self.run(SKAction.playSoundFileNamed("game_over.mp3", waitForCompletion: false))
            
            if self.healthArray.count > 0 {
                let liveNode = self.healthArray.first
                liveNode!.removeFromParent()
                self.healthArray.removeFirst()
                
                if self.healthArray.count == 0 {
                    //GAME OVER screen segue
                    let transition = SKTransition.flipVertical(withDuration: 0.5)
                    let gameOverScene = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    gameOverScene.score = self.score
                    self.view?.presentScene(gameOverScene, transition: transition)
                }
            }
        })
        actionArray.append(SKAction.removeFromParent())
        
        germ.run(SKAction.sequence(actionArray))
        
        
    }
    
    //allows test buttons to be recognized with touch, will be hidden when bridged with EMG sensors
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        let moveLeftAction = SKAction.moveBy(x: 80, y: 0, duration: 0.1)
        let moveRightAction = SKAction.moveBy(x: -80, y: 0, duration: 0.1)
        
        
        if let location = touch?.location(in: self) {
            if directionOneButton.contains(location) {
                print("direction ONE Tapped")
                
                player.run(moveRightAction)
            } else if directionTwoButton.contains(location) {
                print("direction TWO Tapped")
                player.run(moveLeftAction)
            } else if canonFireButton.contains(location) {
                print("FIRE!!!!")
                fireLaser()
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    func fireLaser() {
        self.run(SKAction.playSoundFileNamed("fire.mp3", waitForCompletion: false))
        
        let laserNode = SKSpriteNode(imageNamed: "ammo")
        laserNode.size = CGSize(width: 40, height: 50)
        laserNode.position = player.position
        laserNode.position.y += 5
        
        laserNode.physicsBody = SKPhysicsBody(circleOfRadius: laserNode.size.width / 2)
        laserNode.physicsBody?.isDynamic = true
        
        laserNode.physicsBody?.categoryBitMask = laserCategory
        laserNode.physicsBody?.contactTestBitMask = germCategory
        laserNode.physicsBody?.collisionBitMask = 0
        laserNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(laserNode)
        
        let animationDuration:TimeInterval = 0.3
        
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        laserNode.run(SKAction.sequence(actionArray))
        
        
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & laserCategory) != 0 && (secondBody.categoryBitMask & germCategory) != 0 {
            laserDidCollideWithGerm(laserNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    
    func laserDidCollideWithGerm (laserNode:SKSpriteNode, alienNode:SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "Collide")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explode.mp3", waitForCompletion: false))
        
        laserNode.removeFromParent()
        alienNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 1)) {
            explosion.removeFromParent()
        }
        
        score += 3
        
        
    }
    
    override func didSimulatePhysics() {
        
        //player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
