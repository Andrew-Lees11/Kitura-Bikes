//
//  CrossSlice.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class CrossSlice: GameMap {
    
    public override init()  {
        obstacles.append(Obstacle(height: 50, width: 1, x: GameBoard.BOARD_SIZE / 2 - 25, y: GameBoard.BOARD_SIZE / 2));
        obstacles.append(Obstacle(height: 1, width: 24, x: GameBoard.BOARD_SIZE / 2, y: GameBoard.BOARD_SIZE / 2 - 24));
        obstacles.append(Obstacle(height: 1, width: 24, x: GameBoard.BOARD_SIZE / 2, y: GameBoard.BOARD_SIZE / 2 + 1));
        
        movingObstacles.append(MovingObstacle(height: 1, width: 5, x: GameBoard.BOARD_SIZE / 2, y: GameBoard.BOARD_SIZE / 8, xDir: 0, yDir: 1));
        movingObstacles.append(MovingObstacle(height: 1, width: 5, x: GameBoard.BOARD_SIZE / 2, y: (GameBoard.BOARD_SIZE / 8) * 7, xDir: 0, yDir: -1));
        movingObstacles.append(MovingObstacle(height: 5, width: 1, x: GameBoard.BOARD_SIZE / 8, y: GameBoard.BOARD_SIZE / 2, xDir: 1, yDir: 0));
        movingObstacles.append(MovingObstacle(height: 5, width: 1, x: (GameBoard.BOARD_SIZE / 8) * 6, y: GameBoard.BOARD_SIZE / 2, xDir: -1, yDir: 0));
        
        self.startingPoints = [
            GameBoard.Point(x: GameBoard.BOARD_SIZE / 2 - 15, y: GameBoard.BOARD_SIZE / 2 - 15)!,
            GameBoard.Point(x: GameBoard.BOARD_SIZE / 2 + 15, y: GameBoard.BOARD_SIZE / 2 - 15)!,
            GameBoard.Point(x: GameBoard.BOARD_SIZE / 2 - 15, y: GameBoard.BOARD_SIZE / 2 + 15)!,
            GameBoard.Point(x: GameBoard.BOARD_SIZE / 2 + 15, y: GameBoard.BOARD_SIZE / 2 + 15)!
        ]
        self.startingDirections = [DIRECTION.UP, DIRECTION.RIGHT, DIRECTION.DOWN, DIRECTION.LEFT]
    }
}
