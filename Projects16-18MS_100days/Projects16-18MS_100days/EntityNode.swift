//
//  EntityNode.swift
//  Projects16-18MS_100days
//
//  Created by user228564 on 2/26/23.
//

import SpriteKit

enum EntityType {
    case good
    case bad
}

class DuckNode: SKNode {

    static let ducks = ["brown", "white", "yellow"]
    var type: EntityType = .good
    var points = 100
    
    func configure(at position: CGPoint, type: EntityType, points: Int, xScale: CGFloat, yScale: CGFloat) {
        self.position = position
        self.type = type
        self.points = points
        
        let duckPrefix = "duck" + (type == .good ? "_target_" : "_")
        let duck = SKSpriteNode(imageNamed: duckPrefix + DuckNode.ducks.randomElement()!)
        duck.zPosition = 0.1
        duck.position = CGPoint(x: 0, y: 100)
        addChild(duck)

        self.xScale = xScale
        self.yScale = yScale
    }
}

