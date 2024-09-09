import SpriteKit
import GameplayKit

public class GameScene: SKScene {
    
    private var ground: SKSpriteNode!
    private var cities: [SKSpriteNode] = []
    private var missiles: [SKSpriteNode] = []
    private var explosions: [SKSpriteNode] = []
    private var score = 0
    private var scoreLabel: SKLabelNode!
    
    public override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Create ground
        ground = SKSpriteNode(color: .white, size: CGSize(width: size.width, height: 20))
        ground.position = CGPoint(x: size.width / 2, y: 10)
        addChild(ground)
        
        // Create cities
        for i in 0..<3 {
            let city = SKSpriteNode(color: .white, size: CGSize(width: 30, height: 30))
            city.position = CGPoint(x: CGFloat(i + 1) * size.width / 4, y: 30)
            addChild(city)
            cities.append(city)
        }
        
        // Create score label
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Courier"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 50, y: size.height - 30)
        addChild(scoreLabel)
        
        // Start spawning missiles
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(spawnMissile),
                SKAction.wait(forDuration: 1.5)
            ])
        ))
    }
    
    private func spawnMissile() {
        let missile = SKSpriteNode(color: .white, size: CGSize(width: 4, height: 12))
        missile.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height)
        addChild(missile)
        missiles.append(missile)
        
        let moveAction = SKAction.move(to: CGPoint(x: CGFloat.random(in: 0...size.width), y: 0), duration: 5)
        let removeAction = SKAction.removeFromParent()
        missile.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    public override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        
        let explosion = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 20))
        explosion.position = location
        addChild(explosion)
        explosions.append(explosion)
        
        let expandAction = SKAction.scale(to: 2, duration: 0.5)
        let fadeAction = SKAction.fadeOut(withDuration: 0.5)
        let removeAction = SKAction.removeFromParent()
        explosion.run(SKAction.sequence([expandAction, fadeAction, removeAction]))
    }
    
    public override func update(_ currentTime: TimeInterval) {
        for missile in missiles {
            for explosion in explosions {
                if missile.frame.intersects(explosion.frame) {
                    missile.removeFromParent()
                    if let index = missiles.firstIndex(of: missile) {
                        missiles.remove(at: index)
                    }
                    score += 10
                    scoreLabel.text = "Score: \(score)"
                }
            }
            
            for city in cities {
                if missile.frame.intersects(city.frame) {
                    missile.removeFromParent()
                    if let index = missiles.firstIndex(of: missile) {
                        missiles.remove(at: index)
                    }
                    city.removeFromParent()
                    if let index = cities.firstIndex(of: city) {
                        cities.remove(at: index)
                    }
                }
            }
        }
        
        if cities.isEmpty {
            let gameOverLabel = SKLabelNode(text: "Game Over")
            gameOverLabel.fontName = "Courier"
            gameOverLabel.fontSize = 40
            gameOverLabel.fontColor = .white
            gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
            addChild(gameOverLabel)
            
            removeAllActions()
        }
    }
}
