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
    
    
    
    var background:SKEmitterNode!
    var player: SKSpriteNode!
    
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var gameTimer:Timer!
    
    var possibleAliens = ["bacteria1", "bacteria2", "bacteria3", "bacteria4"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let laserCategory:UInt32 = 0x1 << 0
    
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    var healthArray: [SKSpriteNode]!
    
    override func didMove(to view: SKView) {
        
        loadHealth()
        
        background = SKEmitterNode(fileNamed: "Background")
        background.position = CGPoint(x: 0, y: 0)
        background.advanceSimulationTime(10)
        self.addChild(background)
        
        
        
        
        background.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "anti_body")
        
        
        player.position = CGPoint(x: self.frame.size.width / 4, y: player.size.height / 2 + 50)
        player.size = CGSize(width: 80, height: 80)
        self.addChild(player)
        
        
        
        
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 45, y: self.frame.size.height - 120)
        scoreLabel.fontName = "GOptima-ExtraBlack"
        scoreLabel.fontSize = 65
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        self.addChild(scoreLabel)
        
        var timeInterval = 4.0
        
        if UserDefaults.standard.bool(forKey: "difficult") {
            timeInterval = 2.0
        }
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true)
        
        /* guard let directionOneButton = directionOneButton,
            let directionTwoButton = directionTwoButton,
            let canonFireButton = canonFireButton else {return}
 */
        directionOneButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        directionOneButton.position = CGPoint(x: self.frame.minX + 100, y: self.frame.minY + 100)
        
        directionTwoButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        directionTwoButton.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.minY + 100)
        
        canonFireButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        canonFireButton.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.minY + 250)

        
        
        self.addChild(directionOneButton)
        self.addChild(directionTwoButton)
        self.addChild(canonFireButton)
        
        
        
        
        /*
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
        */
        
        
    }
    
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
    
    
    
    func addEnemy () {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        alien.size = CGSize(width: 80, height: 80)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = laserCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        
        
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
        
        alien.run(SKAction.sequence(actionArray))
        
    
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            if directionOneButton.contains(location) {
                print("direction ONE Tapped")
            } else if directionTwoButton.contains(location) {
                print("direction TWO Tapped")
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
        laserNode.physicsBody?.contactTestBitMask = alienCategory
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
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & laserCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
           torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    
    func torpedoDidCollideWithAlien (torpedoNode:SKSpriteNode, alienNode:SKSpriteNode) {
    
        let explosion = SKEmitterNode(fileNamed: "Collide")!
        explosion.position = alienNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explode.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        alienNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 2)) { 
            explosion.removeFromParent()
        }
        
        score += 3
        
        
    }
    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 50
        
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
