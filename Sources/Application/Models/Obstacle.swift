//
//  Obstacle.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//


public class Obstacle: Codable, Hashable {
    public var hashValue: Int
    
    public static func == (lhs: Obstacle, rhs: Obstacle) -> Bool {
        return lhs.height == rhs.height &&
               lhs.width == rhs.width &&
               lhs.x == rhs.x &&
               lhs.y == rhs.y
    }
    
    
    public let height: Int
    
    public let width: Int
    
    public var x: Int
    
    public var y: Int
    
    init(height: Int, width: Int, x: Int, y: Int) {
        self.height = height
        self.width = width
        self.x = x
        self.y = y
    }
}
