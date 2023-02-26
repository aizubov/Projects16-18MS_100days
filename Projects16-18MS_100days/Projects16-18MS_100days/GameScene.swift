//
//  GameScene.swift
//  Projects16-18MS_100days
//
//  Created by user228564 on 2/26/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameTimer: Timer?
    var spawnTimer: Timer?
    
    var bubbles: SKEmitterNode!
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!
    var possibleEnemies = ["fish_1", "fish_2", "fish_3", "fish_4", "fish_5",
    "bad_1", "bad_2", "bad_3"]
    
    let scoresDict = ["GoodBig": 50, "GoodMedium": 100, "GoodSmall": 200, "Bad": -150]

    var bullets: BulletsNode!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var timerLabel: SKLabelNode!
    var timer = 60 {
        didSet {
            timerLabel.text = "\(timer)s"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .blue
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 500, y: 70)
        background.zPosition = -1
        background.xScale = 0.55
        background.yScale = 0.55
        addChild(background)
        
        bubbles = SKEmitterNode(fileNamed: "bubbles")
        bubbles.position = CGPoint(x: 700, y: 60)
        bubbles.zPosition = -1.1
        bubbles.advanceSimulationTime(10)
        addChild(bubbles)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 8, y: 700)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 48
        addChild(scoreLabel)
        
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.text = "30s"
        timerLabel.position = CGPoint(x: 552, y: 700)
        timerLabel.horizontalAlignmentMode = .right
        timerLabel.fontSize = 48
        addChild(timerLabel)
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "GAME OVER!"
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.fontSize = 68
        gameOverLabel.zPosition = 1
        
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "NEW GAME"
        newGameLabel.position = CGPoint(x: 512, y: 324)
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.name = "newGame"
        newGameLabel.fontSize = 38
        newGameLabel.zPosition = 1
        

        bullets = BulletsNode()
        bullets.configure(at: CGPoint(x: 875, y: 700))
        bullets.name = "bullets"
        addChild(bullets)
        
        physicsWorld.gravity = .zero

        startGame()
    }

    func startGame() {

        score = 0
        timer = 30
        bullets.reload()
        gameOverLabel.removeFromParent()
        newGameLabel.removeFromParent()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decreaseTimer), userInfo: nil, repeats: true)
        spawnTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(createEntity), userInfo: nil, repeats: true)
    }
    
    func gameOver() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        addChild(gameOverLabel)
        addChild(newGameLabel)
    }
    
    @objc func decreaseTimer() {
        timer -= 1

        if timer <= 0 {
            gameOver()
        }
    }
    

    @objc func createEntity() {

        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        
        let yPosition = Int.random(in: 100...650)
        let scaler = Int.random(in: 1...3)
        
        if yPosition > 350 && yPosition < 500 {
            sprite.position = CGPoint(x: -200, y: yPosition)

        } else {
            sprite.position = CGPoint(x: 1200, y: yPosition)
        }

        if enemy.starts(with: "bad") {
            sprite.name = "Bad"
        } else if enemy.starts(with: "fish") && scaler == 3 {
            sprite.name = "GoodBig"
        } else if enemy.starts(with: "fish") && scaler == 2 {
            sprite.name = "GoodMedium"
        } else if enemy.starts(with: "fish") && scaler == 1 {
            sprite.name = "GoodSmall"
        }
        
        sprite.zPosition = 0.2
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 0
        
        if yPosition > 350 && yPosition < 500 {
            sprite.physicsBody?.velocity = CGVector(dx: 600/scaler, dy: 0)

        } else {
            sprite.physicsBody?.velocity = CGVector(dx: -600/scaler, dy: 0)
        }
        sprite.xScale = 0.2 * CGFloat(scaler)
        sprite.yScale = 0.2 * CGFloat(scaler)
        sprite.physicsBody?.angularVelocity = 0.5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        var nodeTapped = false
        
        for node in tappedNodes {
            if node.name == "newGame" {
                startGame()
                return
            }
            
            if timer > 0 {
                for (key, value) in scoresDict {
                    if node.name == key {
                        nodeTapped = true
                        
                        if !bullets.remains() {
                            showReload()
                            return
                        }
                        bullets.decrease()
                        
                        score += value
                        showTappedScore(score: value, position: location)
                        
                        
                        node.removeFromParent()
                        break
                    }
                }
                
                if node.name == "bullets" {
                    bullets.reload()
                    
                    return
                }
            }
        }
    
    
        if timer > 0 && !nodeTapped {
            if !bullets.remains() {
                showReload()
                return
            }
            bullets.decrease()

            score -= 50
            showTappedScore(score: -50, position: location)
        }
    }
    
    func showReload() {
        let reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
        reloadLabel.text = "OUT OF AMMO!"
        reloadLabel.position = CGPoint(x: 512, y: 384)
        reloadLabel.horizontalAlignmentMode = .center
        reloadLabel.fontSize = 80
        reloadLabel.fontColor = UIColor.red
        reloadLabel.zPosition = 1
        addChild(reloadLabel)

        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let removeAction = SKAction.customAction(withDuration: 0) { (reloadLabel, _) in
            reloadLabel.removeFromParent()
        }
        let sequence = SKAction.sequence([fadeOut, removeAction])
        reloadLabel.run(sequence)
        
    }
    
    func showTappedScore(score: Int, position: CGPoint) {
        var scoreText = ""
        var textColor: UIColor!
        var outlineColor: UIColor!

        if score > 0 {
            scoreText += "+"
            textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            outlineColor = UIColor.green
        }
        else {
            textColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
            outlineColor = UIColor(red: 1, green: 0.45, blue: 0.45, alpha: 1)
        }
        scoreText += String(score)
        
        let tmpScoreLabel = SKLabelNode()
        tmpScoreLabel.horizontalAlignmentMode = .center
        tmpScoreLabel.zPosition = 1
        tmpScoreLabel.position = position
        tmpScoreLabel.attributedText = getTappedScoreAttributes(for: scoreText, color: textColor, outline: outlineColor)
        addChild(tmpScoreLabel)

        let fadeAction = SKAction.fadeOut(withDuration: 1)
        let removeAction = SKAction.customAction(withDuration: 1) { (scoreLabel, _) in
            scoreLabel.removeFromParent()
        }
        let sequence = SKAction.sequence([fadeAction, removeAction])
        tmpScoreLabel.run(sequence)
    }
    
    func getTappedScoreAttributes(for text: String, color: UIColor, outline: UIColor) -> NSMutableAttributedString {
        let attStr: NSMutableAttributedString = NSMutableAttributedString(string: text)
        let scoreFont = UIFont(name: "Chalkduster", size: 38)
        attStr.addAttribute(.font, value: scoreFont as Any, range: NSMakeRange(0, attStr.length))
        attStr.addAttribute(.foregroundColor, value: color as Any, range: NSMakeRange(0, attStr.length))
        attStr.addAttribute(.strokeColor, value: outline as Any, range: NSMakeRange(0, attStr.length))
        attStr.addAttribute(.strokeWidth, value: -3.0, range: NSMakeRange(0, attStr.length))

        return attStr
    }
}
