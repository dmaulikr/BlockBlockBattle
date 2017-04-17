//
//  GameScene.swift
//  block
//
//  Created by Tomoyuki Hayakawa on 2017/03/20.
//  Copyright © 2017年 Tomoyuki Hayakawa. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    // ボールノード
    var ball : SKSpriteNode!
    // パッドノード
    var pad : SKSpriteNode!
    
    var playerMotionManager : CMMotionManager!
    var speedX : Double = 0.0
    
    var vecXo : Int = 0
    var vecYo : Int = 0
    
    // 画面サイズの取得
    let screenSize = UIScreen.main.bounds.size
    
    override func didMove(to view: SKView) {
        
        // 画面端に物理ボディを設定する
        //self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        // ノードを取得
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        pad = self.childNode(withName: "pad") as! SKSpriteNode
        
        // ボールの最初の方向
        let rand = arc4random() % 4
        switch rand {
        case 0:
            vecXo = 50
            vecYo = 50
        case 1:
            vecXo = 50
            vecYo = -50
        case 2:
            vecXo = -50
            vecYo = 50
        case 3:
            vecXo = -50
            vecYo = -50
        default:
            break
        }
        print(vecXo, vecYo)
        ball.physicsBody?.applyImpulse(CGVector(dx: vecXo, dy: vecYo))
     
        let border = SKPhysicsBody(edgeLoopFrom: (view.scene?.frame)!)
        border.friction = 0
        self.physicsBody = border
        
        self.physicsWorld.contactDelegate = self
        
        // MotionManagerを生成
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        startAccelerometer()
    }
    
// タッチでパッドを移動
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch  in touches {
//            let touchLocation = touch.location(in: self)
//            pad.position.x = touchLocation.x
//        }
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let touchLocation = touch.location(in: self)
//            pad.position.x = touchLocation.x
//        }
//    }
    
    func startAccelerometer() {
        // 加速度を取得する
        let handler : CMAccelerometerHandler = {(CMAccelerometerData:CMAccelerometerData?, error:Error?) -> Void in
            self.speedX += CMAccelerometerData!.acceleration.x
            // プレイヤーの中心位置を設定
            var posX = self.pad.position.x + (CGFloat(self.speedX) * 3.5)
            
            // padの位置を修正
            if posX <= -self.screenSize.width + (self.pad.frame.width / 2) {
                self.speedX = 0
                posX = -self.screenSize.width + (self.pad.frame.width / 2)
            }
            if posX >= self.screenSize.width - (self.pad.frame.width / 2) {
                self.speedX = 0
                posX = self.screenSize.width - (self.pad.frame.width / 2)
            }
            self.pad.position.x = posX
        }
        // 加速度の開始
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
    // バーとボールの衝突判定
    func didBegin(_ contact: SKPhysicsContact) {
        
        // パーティクルの作成
        let sparkParticle = SKEffectNode(fileNamed: "sparkParticle.sks")
        let magicParticle = SKEffectNode(fileNamed: "magicParticle.sks")
        
        // 接触座標にパーティクルを放出するようにする
        sparkParticle!.position = CGPoint(x:contact.contactPoint.x, y:contact.contactPoint.y)
        magicParticle!.position = CGPoint(x:contact.contactPoint.x, y:contact.contactPoint.y)
        // 0.5秒ごシーンから消すアクションを作成する
        let spark1 = SKAction.wait(forDuration: 0.5)
        let spark2 = SKAction.removeFromParent()
        let sparkAll = SKAction.sequence([spark1, spark2])
        
        let magic1 = SKAction.wait(forDuration: 0.5)
        let magic2 = SKAction.removeFromParent()
        let magicAll = SKAction.sequence([magic1, magic2])
        
        self.addChild(magicParticle!)
        
        // ぶつかった物体を格納
        let bodyAName = contact.bodyA.node?.name
        let bodyBName = contact.bodyB.node?.name
        
        // ぶつかった物体がボールとバーの時
        if bodyAName == "ball" && bodyBName == "bar" || bodyAName == "bar" && bodyBName == "ball"{
            if bodyAName == "bar" {
                contact.bodyA.node?.removeFromParent()
                // パーティクルをシーンに追加する
                self.addChild(sparkParticle!)
                //アクションを実行する
                sparkParticle!.run(sparkAll)
            } else if bodyBName == "bar" {
                contact.bodyB.node?.removeFromParent()
                // パーティクルをシーンに追加する
                self.addChild(sparkParticle!)
                //アクションを実行する
                sparkParticle!.run(sparkAll)
            }
        }
        
        magicParticle!.run(magicAll)
        
    }
    
    
}
