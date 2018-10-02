//
//  HulkSmash.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class HulkSmash: GameMap {
    public override init() {
        super.init()
        createPair(x: 10, y: 10);
        createPair(x: 30, y: GameBoard.BOARD_SIZE / 2 - 5);
        createPair(x: 10, y: GameBoard.BOARD_SIZE - 20);
        
        self.startingPoints = [
            GameBoard.Point(x: GameBoard.BOARD_SIZE / 2 - 10, y: 10),
            GameBoard.Point(x: GameBoard.BOARD_SIZE / 2 + 10, y: 10),
            GameBoard.Point(x: GameBoard.BOARD_SIZE / 2 - 10, y: GameBoard.BOARD_SIZE - 10),
            GameBoard.Point(x: GameBoard.BOARD_SIZE / 2 + 10, y: GameBoard.BOARD_SIZE - 10)
        ]
        
        self.startingDirections = [
            DIRECTION.DOWN, DIRECTION.DOWN, DIRECTION.UP, DIRECTION.UP
        ]
    }
    
    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    private func createPair(x: Int, y: Int) {
        movingObstacles.append(MovingObstacle(height: 2, width: 10, x: x, y: y, xDir: -1, yDir: 0));
        movingObstacles.append(MovingObstacle(height: 2, width: 10, x: GameBoard.BOARD_SIZE - (x + 3), y: y, xDir: 1, yDir: 0));
        
        // [
        obstacles.append(Obstacle(height: 2, width: 14, x: 0, y: y - 2));
        obstacles.append(Obstacle(height: 2, width: 2, x: 2, y: y - 2));
        obstacles.append(Obstacle(height: 2, width: 2, x: 2, y: y + 10));
        
        // ]
        obstacles.append(Obstacle(height: 2, width: 14, x: GameBoard.BOARD_SIZE - 3, y: y - 2));
        obstacles.append(Obstacle(height: 2, width: 2, x: GameBoard.BOARD_SIZE - 5, y: y - 2));
        obstacles.append(Obstacle(height: 2, width: 2, x: GameBoard.BOARD_SIZE - 5, y: y + 10));
    }
}
