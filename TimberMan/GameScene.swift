//
//  GameScene.swift
//  TimberMan
//
//  Created by Arthur Dos Reis on 07/07/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK: Declaração das principais variaveis
    
    var comecou:Bool = false
    var escalaBarra:CGFloat = 1.0
    
    var podeJogar:Bool = true // para bloquear o jogo quando perder
    var podeReiniciar:Bool = false // função para reiniciar o jogo
    
    let somBate:SKAction = SKAction.playSoundFileNamed("somBolhaPop.wav", waitForCompletion: false) // Som 1
    let somPancada:SKAction = SKAction.playSoundFileNamed("pancada.wav", waitForCompletion: false) // Som 2
    
    var lado:Bool = false // Varivel para saber em qual lado o jogador tocou, para fazer a animação do barril.
    
    var pontos:Int = 0 // Contador de pontos
    
    let textoPontos = SKLabelNode(fontNamed: "True Crimes") // Fonte pontos
    let textoFimDeJogo = SKLabelNode(fontNamed: "True Crimes") // Fonte texto jogo
    
    let barraContorno = SKSpriteNode(imageNamed: "barraOutline") // Barra de tempo
    var barra:SKShapeNode = SKShapeNode() // Barra de tempo
    
    var meuBg = SKSpriteNode(imageNamed: "imagemFundo") // Inicialização da variavel que vai armazenar o fundo do cenario.
    var felpudo = SKSpriteNode(imageNamed: "playerIdle") // Inicialização da variavel que vai armazenar o personagem principal.
    
    var listaBarris:[SKSpriteNode] = [] // armazenar os barris que estão sendo gerados no jogo
    
    // MARK: Função didMove
    override func didMove(to view: SKView) {
        
        //MARK: Criando e configurando o plano de fundo
        
        self.backgroundColor = .blue
        meuBg.size.width = self.size.width
        meuBg.size.height = self.size.height
        meuBg.position = CGPoint(x: self.frame.midX, y: self.frame.midY) //
        meuBg.zPosition = -1 // Ordena as camadas, nesse caso está colocando o background na ultima camada.
        self.addChild(meuBg)
        
        //MARK: Configurando e criando a barra de tempo
        
        barraContorno.position = CGPoint(x: frame.midX, y: frame.maxY-100)
        barraContorno.texture?.filteringMode = .nearest
        barraContorno.zPosition = 100
        self.addChild(barraContorno)
        
        barra = SKShapeNode(rect: CGRect(origin: CGPoint(x: 0, y: 0), size: barraContorno.frame.size))
        barra.fillColor = UIColor.red
        barra.strokeColor = UIColor.clear
        barra.position = CGPoint (x: barraContorno.frame.minX, y: barraContorno.frame.minY)
        barra.zPosition = 99
        barraContorno.setScale(1.15) // Escala do contorno deve ser declarada depois para nao influenciar no tamanho da barra
        self.addChild(barra)
        
        //MARK: Inserindo e configurando o personagem
        
        felpudo.position = CGPoint(x: self.frame.midX-90, y: 135)
        self.addChild(felpudo)
        
        //MARK: Iniciar o jogo criando barris
        
        self.iniciarCena()
        
        //MARK: Configurando o texto
        
        //Pontos
        textoPontos.text = "\(pontos)"
        textoPontos.fontSize = 72
        textoPontos.fontColor = .white
        textoPontos.horizontalAlignmentMode = .center
        textoPontos.verticalAlignmentMode = .top
        textoPontos.position = CGPoint(x: frame.midX, y: frame.maxY - 150)
        textoPontos.zPosition = 100
        self.addChild(textoPontos)
        
        //Fim de jogo
        
        textoFimDeJogo.horizontalAlignmentMode = .center
        textoFimDeJogo.verticalAlignmentMode = .top
        textoFimDeJogo.position = CGPoint(x: frame.midX, y: frame.midY)
        textoFimDeJogo.zPosition = 100
        textoFimDeJogo.isHidden = true
        self.addChild(textoFimDeJogo)
        
        
    }
    
    //MARK: Função bater a esquerda
    func bateEsquerda(){
        
        lado = false
        felpudo.position = CGPoint(x: self.frame.midX - 90, y: 135)
        felpudo.xScale = 1
        felpudo.run(SKAction.setTexture(SKTexture(imageNamed: "playerHit"))) // Trocar a aparencia do personagem
        felpudo.run(SKAction.sequence([SKAction.wait(forDuration: 0.15), SKAction.setTexture(SKTexture(imageNamed: "playerIdle"))])) // Apos um tempo de 0.15 o personagem volta a aparencia padrão
        
        if(listaBarris[1].name == "Esq"){
            perdeu()
        }else{
            pontua()
        }
        
        animaBarril(lado)
    }
    
    //MARK: Função bater a direita
    func bateDireita(){
        
        lado = true
        felpudo.position = CGPoint(x: self.frame.midX + 90, y: 135)
        felpudo.xScale = -1
        felpudo.run(SKAction.setTexture(SKTexture(imageNamed: "playerHit"))) // Trocar a aparencia do personagem
        felpudo.run(SKAction.sequence([SKAction.wait(forDuration: 0.15), SKAction.setTexture(SKTexture(imageNamed: "playerIdle"))])) // Apos um tempo de 0.15 o personagem volta a aparencia padrão
        
        if(listaBarris[1].name == "Dir"){
            perdeu()
        }else{
            pontua()
        }
        
        animaBarril(lado)
        
    }
    
    //MARK: Função para dar animação para o barril
    func animaBarril(_ lado:Bool){
        
        let dist:CGFloat = lado ? -200 : 200 // Verificar qual lado o jogador clicou, para atribuir um valor e movimentar o barril para o lado oposto do clique
        
        listaBarris[0].run(SKAction.sequence([SKAction.moveBy(x: dist, y: 30, duration: 0.25), SKAction.removeFromParent()]))
        listaBarris[0].run(SKAction.rotate(byAngle: dist/5, duration: 0.25))
        listaBarris.remove(at: 0)
        
        empurraBarril()
        
    }
    
    //MARK: Função para empurrar os barris para baixo
    func empurraBarril(){
        for b in listaBarris{
            b.run(SKAction.moveBy(x: 0, y: -b.frame.height, duration: 0.15))
        }
        
        criarBarril(12)
    }
    
    //MARK: Função par criar novos barris a medida que são removidos
    func criarBarril(_ contador:Int){
        
        // Parte do codigo dedicada para que os barris sejam gerados de forma aleatoria.
        let sorteio = Int.random(in: 0...10)
        var imagemUrl = ""
        var escalaX:CGFloat = 1
        var px:CGFloat = 0
        var nome = ""
        
        //if else para gerar os barris aleatorios
        if(contador > 2){
            
            if(sorteio < 5){
                imagemUrl = "barril"
                px = self.frame.midX
                nome = "Meio"
            } else if(sorteio < 8){
                imagemUrl = "barrilInimigo"
                px = self.frame.midX+30
                nome = "Dir"
                escalaX = 1
            }else {
                imagemUrl = "barrilInimigo"
                px = self.frame.midX-30
                nome = "Esq"
                escalaX = -1
            }
            
        }else{
            imagemUrl = "barril"
            px = self.frame.midX
            nome = "Meio"
        }
        // -----------------------------
        
        let barril = SKSpriteNode(imageNamed: imagemUrl)
        barril.position = CGPoint(x: px, y: 135 + CGFloat(contador) * barril.size.height)
        barril.xScale = escalaX
        barril.name = nome
        listaBarris.append(barril)
        self.addChild(barril)
        
    }
    
    //MARK: Função perder
    func perdeu(){
        self.run(somPancada)
        
        if(!lado){
            felpudo.run(SKAction.moveBy(x: -300, y: 50, duration: 0.25))
            felpudo.run(SKAction.rotate(byAngle: -30, duration: 0.25))
        }else{
            felpudo.run(SKAction.moveBy(x: 300, y: 50, duration: 0.25))
            felpudo.run(SKAction.rotate(byAngle: 30, duration: 0.25))
        }
        
        textoFimDeJogo.text = "Game Over"
        textoFimDeJogo.fontSize = 72
        textoFimDeJogo.fontColor = .yellow
        textoFimDeJogo.isHidden = false
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.run({
            
            self.textoFimDeJogo.isHidden = false
            self.textoFimDeJogo.text = "Toque para Reiniciar"
            self.textoFimDeJogo.fontColor = .green
            self.textoFimDeJogo.fontSize = 32
            self.podeReiniciar = true
            
        })]))
        
        podeJogar = false
        
    }
    
    //MARK: Função de reiniciar
    func reinicio(){
        felpudo.zRotation = 0
        felpudo.position = CGPoint(x: self.frame.midX-90, y: 135)
        pontos = 0
        textoPontos.text = "\(pontos)"
        comecou = false
        escalaBarra = 1
        textoFimDeJogo.isHidden = true
        
        for b in listaBarris{
            b.removeFromParent()
            listaBarris.remove(at: 0)
        }
        listaBarris = []
        iniciarCena()
    }
    
    //MARK: Iniciar novamente o jogo
    func iniciarCena() {
        
        for i in 0..<13{
            
            criarBarril(i)
            
        }
        
        pontos = 0
        podeJogar = true
        
    }
    
    //MARK: Função para gerar pontuação
    func pontua(){
        pontos += 1
        textoPontos.text = ("\(pontos)")
        escalaBarra += 0.1
    }
    
    //MARK: Função de capturar o toque na tela
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(podeReiniciar){
            
            podeReiniciar = false
            self.reinicio()
            
        }else if(podeJogar){
            comecou = true
            
            for touch in touches {
                let location = touch.location(in: self)
                self.run(somBate)
                if(location.x > self.frame.midX){ // Verificar se o jogador tocou na direita
                    bateDireita()
                }else{       // Verificar se o jogador tocou na esquerda
                    
                    bateEsquerda()
                }
                
            }
        }
    }
    
    //MARK: Função de update
    override func update(_ currentTime: TimeInterval) {
        if(escalaBarra>1.0){
            escalaBarra = 1.0
        }
        if(podeJogar && comecou){
            escalaBarra -= 0.01
            if(escalaBarra < 0.1){
                perdeu()
            }
        }
        barra.xScale = escalaBarra
    }
    
}
