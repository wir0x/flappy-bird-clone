//
//  GameScene.swift
//  FlappyBirdClone
//
//  Created by Gonzalo Salazar Velasquez on 12/29/14.
//  Copyright (c) 2014 Gonzalo Salazar Velasquez. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var bird = SKSpriteNode()
    var colorCielo = SKColor()
    var tuboVertical = 130.0
    var tuboTexture1 = SKTexture(imageNamed: "Tubo1")
    var tuboTexture2 = SKTexture(imageNamed: "Tubo2")
    var moverTubosAndRemove = SKAction()
    
    let birdCategory:UInt32 = 1
    let mundoCategory:UInt32 = 2
    let tuboCategory:UInt32 = 4
    let scoreCategory:UInt32 = 8
    
   
    
    var moviendo = SKNode()
    var reiniciar = false
    var tubos = SKNode()
    
    var scoreLabel = SKLabelNode()
    var score = NSInteger()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.addChild(moviendo)
        moviendo.addChild(tubos)
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        self.physicsWorld.contactDelegate = self
        
        // Cielo (fondo)
        colorCielo = SKColor(red: 13.0/255.0, green:197.0/255.0, blue: 207.0/255.0, alpha: 1)
        self.backgroundColor = colorCielo
        
        /*
         * Realizar Movimiento de la ave
         */
        
        // añadir ave1 estatica
        var birdTexture1 = SKTexture(imageNamed: "Ave1")
        birdTexture1.filteringMode = SKTextureFilteringMode.Nearest
        
        // añadir ave2 vuela
        var birdTexture2 = SKTexture(imageNamed: "Ave2")
        birdTexture1.filteringMode = SKTextureFilteringMode.Nearest
        
        // Animacion de la ave
        var animacion = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.2)
        var aleteo = SKAction.repeatActionForever(animacion)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.position = CGPoint(x:self.frame.size.width / 2.4, y: CGRectGetMidY(self.frame))
        bird.runAction(aleteo)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody!.dynamic = true
        bird.physicsBody!.allowsRotation = false
        
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = mundoCategory | tuboCategory
        bird.physicsBody?.contactTestBitMask = mundoCategory | tuboCategory
        
        moviendo.addChild(bird)
        
        
        // Textura del suelo
        var sueloTexture = SKTexture(imageNamed: "Suelo")
        sueloTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        // Movimiento del suelo
        var movimientoSuelo = SKAction.moveByX(-sueloTexture.size().width, y: 0, duration: NSTimeInterval(0.01 * sueloTexture.size().width))
        var resetSuelo = SKAction.moveByX(sueloTexture.size().width,y:0, duration:0.0)
        var moverSueloForever = SKAction.repeatActionForever(SKAction.sequence([movimientoSuelo,resetSuelo]))
        
        
        // añadir el suelo por todo el frame
        for var i:CGFloat = 0; i < self.frame.size.width / (sueloTexture.size().width); ++i {
            var sprite = SKSpriteNode(texture: sueloTexture)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2)
            sprite.runAction(moverSueloForever)
            moviendo.addChild(sprite)
            
        }
        
        var sueloImaginario = SKNode()
        sueloImaginario.position = CGPointMake(0, sueloTexture.size().height / 2)
        sueloImaginario.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, sueloTexture.size().height))
        sueloImaginario.physicsBody?.dynamic = false
        
        sueloImaginario.physicsBody?.categoryBitMask = mundoCategory
        moviendo.addChild(sueloImaginario)
        
        
        // Textura del cielo
        var cieloTexture = SKTexture(imageNamed: "Fondo")
        cieloTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        var moverCieloSprite = SKAction.moveByX(-cieloTexture.size().width, y: 0, duration: NSTimeInterval(0.1 * cieloTexture.size().width))
        var resetCieloSprite = SKAction.moveByX(cieloTexture.size().width, y:0, duration: 0.0)
        var moverSpriteCielo = SKAction.repeatActionForever(SKAction.sequence([moverCieloSprite, resetCieloSprite]))
        
        
        // añadir la tesxtura del cielo
        for var i:CGFloat = 0; i < self.frame.size.width / (cieloTexture.size().width); ++i {
            var sprite = SKSpriteNode(texture: cieloTexture)
            sprite.zPosition = -20
            sprite.runAction(moverSpriteCielo)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + sueloTexture.size().height)
            moviendo.addChild(sprite)
        }
        
        var distanciaAMover = CGFloat(self.frame.size.width + 2.0 * tuboTexture1.size().width)
        var moverTubos = SKAction.moveByX(-distanciaAMover, y: 0.0, duration: NSTimeInterval(0.01 * distanciaAMover))
        var removeTubos = SKAction.removeFromParent()
        moverTubosAndRemove = SKAction.sequence([moverTubos, removeTubos])
        
        var crear = SKAction.runBlock(self.crearTubos)
        var delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        var crearAndDelay = SKAction.sequence([crear, delay])
        var crearAndDelayForever = SKAction.repeatActionForever(crearAndDelay)
    
        
        self.runAction(crearAndDelayForever)
        
        score = 0
        scoreLabel.fontName = " Helvetica-Bold"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height / 4)
        scoreLabel.fontSize = 60
        scoreLabel.alpha = 0.3
        scoreLabel.text = "\(score)"
        self.addChild(scoreLabel)
        
        
    }
    
    func crearTubos() {
        
        tuboTexture1 = SKTexture(imageNamed: "Tubo1")
        tuboTexture1.filteringMode = SKTextureFilteringMode.Nearest
        
        tuboTexture2 = SKTexture(imageNamed: "Tubo2")
        tuboTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        var parTubos = SKNode()
        parTubos.position = CGPointMake(self.frame.size.width + tuboTexture1.size().width * 2, 0)
        parTubos.zPosition = -10
        
        var lugarEspacioEntreTubos = UInt32(self.frame.height / 3)
        var y = arc4random() % lugarEspacioEntreTubos
        
        var tubo1 = SKSpriteNode(texture: tuboTexture1)
        tubo1.position = CGPointMake(0.0, CGFloat(y))
        tubo1.physicsBody = SKPhysicsBody(rectangleOfSize: tubo1.size)
        tubo1.physicsBody?.dynamic = false
        
        tubo1.physicsBody?.categoryBitMask = tuboCategory
        tubo1.physicsBody?.contactTestBitMask = birdCategory
        parTubos.addChild(tubo1)
        
        var tubo2 = SKSpriteNode(texture: tuboTexture2)
        tubo2.position = CGPointMake(0.0, CGFloat(y) + tubo1.size.height + CGFloat(tuboVertical))
        tubo2.physicsBody = SKPhysicsBody(rectangleOfSize: tubo2.size)
        tubo2.physicsBody?.dynamic = false
        
        tubo2.physicsBody?.categoryBitMask = tuboCategory
        tubo2.physicsBody?.contactTestBitMask = birdCategory
        
        parTubos.addChild(tubo2)
        
        var nodoContacto = SKNode()
        nodoContacto.position = CGPointMake(tubo1.size.width/2, CGRectGetMidY(self.frame))
        nodoContacto.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(tubo1.size.width, self.frame.size.height))
        nodoContacto.physicsBody?.dynamic = false
        parTubos.addChild(nodoContacto)
        
        nodoContacto.physicsBody?.categoryBitMask = scoreCategory
        nodoContacto.physicsBody?.contactTestBitMask = birdCategory
        
        parTubos.runAction(moverTubosAndRemove)
        tubos.addChild(parTubos)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        if (moviendo.speed > 0) {
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 8))
        } else if (reiniciar) {
            self.reiniciarJuego()
        }
    }
    
    func reiniciarJuego() {
        bird.position = CGPoint(x: self.frame.size.width/2.5, y:CGRectGetMidY(self.frame))
        bird.physicsBody?.velocity = CGVectorMake(0, 0 )
        bird.physicsBody?.collisionBitMask = mundoCategory | tuboCategory
        bird.speed = 1.0
        reiniciar = false
        moviendo.speed = 1
        
        score = 0
        scoreLabel.text = "\(score)"
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if (moviendo.speed > 0) {
            
            if ((contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory ||
                (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory) {
                    score++
                    scoreLabel.text = "\(score)"
                
            } else {
                moviendo.speed = 0
                
                bird.physicsBody?.collisionBitMask = mundoCategory
                var rotarAve = SKAction.rotateByAngle(0.01, duration: 0.03)
                var stopAve = SKAction.runBlock(frenarAve)
                var secuenciaAve = SKAction.sequence([rotarAve, stopAve])
                bird.runAction(secuenciaAve)

                
                self.removeActionForKey("flash")
                var fondoRojo = SKAction.runBlock(self.setFondoRojo)
                var espera = SKAction.waitForDuration(0.05)
                var fondoBlanco = SKAction.runBlock(setFondoBlanco)
                var fondoCielo = SKAction.runBlock(setFondoCielo)
                var secuenciaAcciones = SKAction.sequence([fondoRojo, fondoBlanco, espera, fondoCielo])
                var repetirSecuencia =  SKAction.repeatAction(secuenciaAcciones, count: 4)
                
                var reiniciarAccion = SKAction.runBlock(reinicia)
                var grupoAcciones = SKAction.group([repetirSecuencia, reiniciarAccion])
                
                self.runAction(repetirSecuencia, withKey:"flash")
                
            }
        }
    }
    
    func frenarAve() {
        bird.speed = 0;
    }
    
    func reinicia() {
        reiniciar = true
    }
    
    
    func setFondoRojo() {
        self.backgroundColor = UIColor.redColor()
    }
    
    
    func setFondoBlanco() {
        self.backgroundColor = UIColor.whiteColor()
    }
    
    
    func setFondoCielo() {
        self.backgroundColor = SKColor(red: 13.0/255.0, green:197.0/255.0, blue: 207.0/255.0, alpha: 1)
    }
    
    
    func acotarMinMax(min: CGFloat, max: CGFloat, valor: CGFloat) -> CGFloat {
        if (valor > max) {
            return max
            
        } else if (valor < min) {
            return min
            
        } else {
            return valor
        }
        
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if (moviendo.speed > 0) {
            bird.zRotation = self.acotarMinMax(-1, max: 0.3, valor: bird.physicsBody!.velocity.dy * (bird.physicsBody!.velocity.dy < 0 ? 0.03 : 0.02))
        }
    
    }
}




















