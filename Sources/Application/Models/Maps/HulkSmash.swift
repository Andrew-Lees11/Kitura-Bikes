//
//  HulkSmash.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class HulkSmash: GameMap {
    public init() {
        createPair(x: 10, y: 10);
        createPair(30, GameBoard.BOARD_SIZE / 2 - 5);
        createPair(10, GameBoard.BOARD_SIZE - 20);
        
        self.startingPoints = [
            GameBoard.Point(GameBoard.BOARD_SIZE / 2 - 10, 10),
            GameBoard.Point(GameBoard.BOARD_SIZE / 2 + 10, 10),
            GameBoard.Point(GameBoard.BOARD_SIZE / 2 - 10, GameBoard.BOARD_SIZE - 10),
            GameBoard.Point(GameBoard.BOARD_SIZE / 2 + 10, GameBoard.BOARD_SIZE - 10)
        ]
        
        self.startingDirections = [
            DIRECTION.DOWN, DIRECTION.DOWN, DIRECTION.UP, DIRECTION.UP
        ]
    }
    
    private func createPair(x: Int, y: Int) {
        movingObstacles.append(MovingObstacle(2, 10, x, y, -1, 0));
        movingObstacles.append(MovingObstacle(2, 10, BOARD_SIZE - (x + 3), y, 1, 0));
        
        // [
        obstacles.append(Obstacle(2, 14, 0, y - 2));
        obstacles.append(Obstacle(2, 2, 2, y - 2));
        obstacles.append(Obstacle(2, 2, 2, y + 10));
        
        // ]
        obstacles.append(Obstacle(2, 14, BOARD_SIZE - 3, y - 2));
        obstacles.append(Obstacle(2, 2, BOARD_SIZE - 5, y - 2));
        obstacles.append(Obstacle(2, 2, BOARD_SIZE - 5, y + 10));
    }
}
