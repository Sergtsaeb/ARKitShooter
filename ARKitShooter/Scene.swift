//
//  Scene.swift
//  ARKitShooter
//
//  Created by Sergelenbaatar Tsogtbaatar on 6/21/17.
//  Copyright © 2017 Sergtsaeb. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    let startTime = Date()
    let remainingLabel = SKLabelNode()
    var timer: Timer?
    var targetsCreated = 0
    var targetCount = 0 {
        didSet {
            remainingLabel.text = "Remaining: \(targetCount)"
        }
    }
    
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        remainingLabel.fontSize = 36
        remainingLabel.fontName = "AmericanTypewriter"
        remainingLabel.color = .white
        remainingLabel.position = CGPoint(x: 0, y: view.frame.midY -
            50)
        addChild(remainingLabel)
        targetCount = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats:
        true) { timer in
            self.createTarget()
        }
    }
    
    func createTarget() {
        if targetsCreated == 20 {
            timer?.invalidate()
            timer = nil
            return
        }
        
        targetsCreated += 1
        targetCount += 1
        
        // The current scene
        guard let sceneView = self.view as? ARSKView else { return }
        
        // Random number generator via
        let random = GKRandomSource.sharedRandom()
        
        // Random x-axis rotation generator
        let xRotation =
            SCNMatrix4ToMat4(SCNMatrix4MakeRotation(Float.pi * 2 *
                random.nextUniform(), 1, 0, 0))
        
        // Random y-axis rotation generator
        let yRotation =
            SCNMatrix4ToMat4(SCNMatrix4MakeRotation(Float.pi * 2 *
                random.nextUniform(), 0, 1, 0))
        
        // Combine them together via simd_mul aka (single instruction, multiple data - multiplier)
        let rotation = simd_mul(xRotation, yRotation)
        
        // Translation on screen (position track)
        // move forward 1.5 meters into the screen
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        // Combine translation with rotation
        let transform = simd_mul(rotation, translation)
        
        // Create an anchor at the final position and add to current scene
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        // Find which nodes were hit
        let hit = nodes(at: location)
        
        // Sprite deletion action and animation
        if let sprite = hit.first {
            let scaleOut = SKAction.scale(to: 2, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let group = SKAction.group([scaleOut, fadeOut])
            let sequence = SKAction.sequence([group, SKAction.removeFromParent()])
            sprite.run(sequence)
            
            targetCount -= 1
            
        }
        
    }
}
