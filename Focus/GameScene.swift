//
//  GameScene.swift
//  Focus
//
//  Created by AbdelGhafour on 8/15/15.
//  Copyright (c) 2015 Abdou23. All rights reserved.
//

import SpriteKit

// Physics
let HeroCategory: UInt32 =      0x1 << 0
let BlockCategory: UInt32 =     0x1 << 1

// Nodes
var hero = SKShapeNode()
var block = SKShapeNode()

// Labels
var scorelabel = SKLabelNode(fontNamed: "STHeitiSC-Medium")

// Vars
var previous = UInt32()
var previousBlock = UInt32()
var score = 0
var highScore = 0

var isScaled = false

// Arrays
var colors = [UIColor]()
var blocks = [SKShapeNode]()

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        physicsWorld.contactDelegate = self
        
        
        colors = [UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.yellowColor(), UIColor.purpleColor(), UIColor.blackColor()]
        
        backgroundColor = UIColor(red: 224 / 255, green: 224 / 255, blue: 224 / 255, alpha: 1.0)
        
        newGame()
        
    }
    
    func newGame() {
        
        createHero()
        createBlock()
        spawnBlock()
        createlabels()
        changeHeroColor()

        score = 0
        scorelabel.text = "\(score)"

    }
    
    func gameOver() {
        
        removeAllChildren()
        removeAllActions()
        newGame()
    }
    
    func createlabels() {
        
        scorelabel.text = "\(score)"
        scorelabel.position = CGPoint(x: size.width / 2, y: size.height  - 200)
        scorelabel.fontSize = 50
        scorelabel.fontColor = SKColor.brownColor()
        addChild(scorelabel)
    }
    
    func createHero() {
        
        hero = SKShapeNode(circleOfRadius: 40)
        hero.fillColor = UIColor.blueColor()
        hero.position = CGPoint(x: size.width / 2, y: 200)
        
        hero.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.categoryBitMask = HeroCategory
        
        addChild(hero)
    }
    

    
    func randomNumber(max: UInt32) -> UInt32 {
        
        
        var randomNumber = arc4random_uniform(max)
        
        while previous == randomNumber {
            
            randomNumber = arc4random_uniform(max)
        }
        
        previous = randomNumber
        
        return randomNumber
    }
    
    func createBlock() {
        
        //var randomColor = Int(arc4random_uniform(3))
//        var minX = UInt32(0)
//        var maxX = UInt32(size.width)
//        randomX = CGFloat(arc4random_uniform(maxX - minX) + minX)
        
        var newX: CGFloat = 62.5
        
        blocks.removeAll(keepCapacity: false)
        for var i = 0; i < 3; i++ {
            
            block = SKShapeNode(rectOfSize: CGSizeMake(125, 30))
            var random = randomNumber(6)
            block.fillColor = colors[Int(random)]
            block.position = CGPoint(x: newX, y: frame.size.height + block.frame.height)
            
            blocks.append(block)
            
            //Physics
            
            block.physicsBody = SKPhysicsBody(rectangleOfSize: block.frame.size)
            block.physicsBody?.affectedByGravity = false
            block.physicsBody?.dynamic = false
            block.physicsBody?.categoryBitMask = BlockCategory
            block.physicsBody?.contactTestBitMask = HeroCategory
            
            
            addChild(block)
            
            var move = SKAction.moveToY(0 - block.frame.height, duration: 2)
            block.runAction(move)
            
            newX = newX + block.frame.size.width
        }
        

    }

    
    func spawnBlock() {
        
        var wait = SKAction.waitForDuration(1)
        var spawnBlock = SKAction.runBlock({
            self.createBlock()
        })
        
        var sequence = SKAction.sequence([wait, spawnBlock])
        runAction(SKAction.repeatActionForever(sequence))
    }
    

    
    func changeHeroColor() {
        
        
        var randomNumber = arc4random_uniform(3)
        
        while previousBlock == randomNumber {
            
            randomNumber = arc4random_uniform(3)
        }
        
        previousBlock = randomNumber
        
        
        var chosenBlock = blocks[Int(previousBlock)]
        println(chosenBlock.fillColor)
        hero.fillColor = chosenBlock.fillColor

    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        
        let firstBody: SKPhysicsBody!
        let secondBody: SKPhysicsBody!
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        } else {
            
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == HeroCategory && secondBody.categoryBitMask == BlockCategory {
            
            if var blockHit = secondBody.node as? SKShapeNode {
                
                if hero.fillColor == blockHit.fillColor {
                    
                    println("Success")
                    blockHit.removeFromParent()
                    
                    score++
                    scorelabel.text = "\(score)"
                    
                    changeHeroColor()
                    
                } else {
                    println("Miss")
                    gameOver()
                }
            }
        }
        
    }
    
    func setHighScore() {
        
        highScore = score
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
//            
//            if isScaled {
//                
//                hero.runAction(SKAction.scaleBy(-1.5, duration: 0.2))
//                
//                isScaled = false
//            }
            
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            

            
            let previous = touch.previousLocationInNode(self)
            
            let translation = hero.position.x + (location.x - previous.x)
            
            hero.position = CGPointMake(translation, hero.position.y)
            

        }
    }
    

    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
//        isScaled = true
//        hero.runAction(SKAction.scaleBy(1.5, duration: 0.2))
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        var lastUpdateTime = NSTimeInterval()
        var timeSinceLastUpdate = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        var wait = SKAction.waitForDuration(3)
        var spawnBlock = SKAction.runBlock({
            self.createBlock()
        })
        
        var sequence = SKAction.sequence([wait, spawnBlock])
        //runAction(SKAction.repeatActionForever(sequence))

    }
}
