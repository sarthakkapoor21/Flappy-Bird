//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Sarthak Kapoor on 01/07/17.
//  Copyright © 2017 SK21. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var background = SKSpriteNode()
    var floor = SKNode()
    var makeTimer = Timer()
//    var removeTimer1 = Timer()
//    var removeTimer2 = Timer()
    var gameOver = false
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var score = 0
    var firstTouch = true
    
    enum ColliderType: UInt32 {
        
        case Bird = 1
        case Object = 2
        case Gap = 4
        
    }
    
    let birdTexture = SKTexture(imageNamed: "flappy1.png")
    
//    func removePipes(timerSent: Timer)
//    {
//        if let pipeSent = timerSent.userInfo as? SKSpriteNode
//        {
//            pipeSent.removeFromParent()
//        }
//    }

    func makePipes()
    {
        var pipe1 = SKSpriteNode()
        var pipe2 = SKSpriteNode()
        let gap = SKNode()

        let pipeTexture1 = SKTexture(image: #imageLiteral(resourceName: "pipe1.png"))
        let pipeTexture2 = SKTexture(image: #imageLiteral(resourceName: "pipe2.png"))
        
        pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe2 = SKSpriteNode(texture: pipeTexture2)
        
        let gapHeight = birdTexture.size().height * 6
        
        let totalRandomMovement = arc4random() % UInt32(self.frame.height/2)
        let pipeMovement = CGFloat(totalRandomMovement) - self.frame.height/4
        
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width/100))
        let removePipes = SKAction.removeFromParent()
        
        let pipeMoveAndRemove = SKAction.sequence([movePipes, removePipes])
        
        pipe1.zPosition = -1
        pipe2.zPosition = -1
        
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + (pipeTexture1.size().height/2) + (gapHeight/2) + pipeMovement)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - (pipeTexture2.size().height/2) - (gapHeight/2) + pipeMovement)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture1.size())
        pipe1.physicsBody!.isDynamic = false
        
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture2.size())
        pipe2.physicsBody!.isDynamic = false
        
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeMovement)
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture1.size().width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        
        pipe1.run(pipeMoveAndRemove)
        pipe2.run(pipeMoveAndRemove)
        gap.run(pipeMoveAndRemove)
        
        self.addChild(pipe1)
        self.addChild(pipe2)
        self.addChild(gap)
        
        
//        removeTimer1 = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(GameScene.removePipes), userInfo: pipe1, repeats: false)
//        removeTimer2 = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(GameScene.removePipes), userInfo: pipe2, repeats: false)
        
        
    }
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupGame()
        
    }
    
    func setupGame()
    {
        
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        let bgAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        
        let makeBGMove = SKAction.repeatForever(SKAction.sequence([bgAnimation, shiftBGAnimation]))
        
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        var i: CGFloat = 0
        
        while i < 3
        {
            background = SKSpriteNode(texture: bgTexture)
            background.zPosition = -2
            
            background.size.height = self.frame.height
            background.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            
            background.run(makeBGMove)
            
            self.addChild(background)
            
            i += 1
        }
        
        bird = SKSpriteNode(texture: birdTexture)
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        bird.run(makeBirdFlap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody!.isDynamic = false
        
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        
        self.addChild(bird)
        
        floor.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        floor.physicsBody?.isDynamic = false
        
        floor.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        floor.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        floor.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(floor)
        
        scoreLabel.text = String(score)
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 100
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + (self.frame.height / 2) - 120)
        
        self.addChild(scoreLabel)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -20)
        

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false
        {
            
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue
            {
                score += 1
                scoreLabel.text = String(score)
            }
            else
            {
                self.speed = 0
                gameOver = true
                gameOverLabel.text = "GAME OVER!\nTap to Play Again"
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 50
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                
                self.addChild(gameOverLabel)
                
            }
            
        }
        else
        {
            makeTimer.invalidate()
        }
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameOver == false && !firstTouch
        {
            bird.physicsBody!.isDynamic = true
            
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 130))
        }
        else if gameOver == false
            {
                firstTouch = false
                
                makePipes()
                
                makeTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)

                bird.physicsBody!.isDynamic = true
            
                bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 130))
            }
            else
            {
                makeTimer.invalidate()
                firstTouch = true
                gameOver = false
                score = 0
                self.speed = 1
                self.removeAllChildren()
                setupGame()
            }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
