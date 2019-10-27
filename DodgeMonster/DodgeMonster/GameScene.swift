//
//  GameScene.swift
//  DodgeMonster
//
//  Created by james luo on 10/26/19.
//  Copyright © 2019 james luo. All rights reserved.
//

import SpriteKit
import GameplayKit
import FirebaseDatabase
import Activ5Device
class GameScene: SKScene {
    var prevNewton = 0
    var newton = 0
    var deviceFound = false
    var connected = false
    var updateVals: Timer!
    private var spinnyNode : SKShapeNode?
    var xCord = [Float] ()
    var yCord = [Float] ()
    
    override func didMove(to view: SKView) {
        
        
        // Get label node from scene and store it for use later
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        updateVals = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reloadDataBase), userInfo: nil, repeats: true)
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    @objc func reloadDataBase(){
        let ref = Database.database().reference()
        ref.child("Object/X").setValue(xCord)
        ref.child("Object/Y").setValue(yCord)
        xCord = []
        yCord = []
    }
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        xCord.append(Float(pos.x))
        yCord.append(Float(pos.y))
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for t in touches { self.touchDown(atPoint: t.location(in: self))
            //print(t)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self))
//            xCord.append(Float(t.location(in: self).x))
//            yCord.append(Float(t.location(in: self).y))
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            //print(t)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
      
        // Called before each frame is rendered
    }
}
