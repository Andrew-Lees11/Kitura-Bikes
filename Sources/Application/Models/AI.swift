//
//  AI.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class AI: Codable, Hashable {
    
    let startX: Int
    let startY: Int
    let height = Player.PLAYER_SIZE
    let width = Player.PLAYER_SIZE
    let takenSpotNumber: Int
    public let startDirection: DIRECTION
    private let ticksTillRandomMove = 20
    private let ticksTillMove = 4
    private let numOfRandomMoves = 0
    private static let CD = 1
    private static let BD = 2
    private var direction: DIRECTION
    private var lastDirection: DIRECTION
    private var x: Int
    private var y: Int
    private var hasMoved = false
    
    public convenience init(map: GameMap, playerNum: Int) {
        self.init(startX: map.startingPoints[playerNum].x, startY: map.startingPoints[playerNum].y, startDirection: map.startingDirections[playerNum], playerNum: playerNum)
    }
    
    public init(startX: Int,startY: Int, startDirection: DIRECTION, playerNum: Int) {
        self.startX = startX
        self.startY = startY
        self.x = startX;
        self.y = startY;
        self.startDirection = startDirection
        self.lastDirection = startDirection
        self.direction = startDirection
        self.takenSpotNumber = playerNum
    }
    
    public func processGameTick(board: [[Int]]) -> DIRECTION {
        return .DOWN
    }
    
    public func asPlayer() -> Player {
        let name = "KituraBot" + String((takenSpotNumber + 1))
        let p = Player(id: name, name: name, playerNum: takenSpotNumber)!
        p.ai = self
        return p
    }
    
}
