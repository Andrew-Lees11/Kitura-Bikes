//
//  Smile.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class Smile: GameMap {
    
    public override init() {
        obstacles.append(Obstacle(height: 12, width: 1, x: (GameBoard.BOARD_SIZE / 10) * 3, y: GameBoard.BOARD_SIZE / 3));
        obstacles.append(Obstacle(height: 12, width: 1, x: (GameBoard.BOARD_SIZE / 10) * 3, y: GameBoard.BOARD_SIZE / 3 + 12));
        obstacles.append(Obstacle(height: 1, width: 11, x: (GameBoard.BOARD_SIZE / 10) * 3, y: GameBoard.BOARD_SIZE / 3 + 1));
        obstacles.append(Obstacle(height: 1, width: 11, x: (GameBoard.BOARD_SIZE / 10) * 3 + 11, y: GameBoard.BOARD_SIZE / 3 + 1));
        movingObstacles.append(MovingObstacle(height: 2, width: 2, x: (GameBoard.BOARD_SIZE / 10) * 3 + 8, y: GameBoard.BOARD_SIZE / 3 + 8, xDir: 1, yDir: 1));
        
        obstacles.append(Obstacle(height: 12, width: 1, x: (GameBoard.BOARD_SIZE / 5) * 3, y: GameBoard.BOARD_SIZE / 3));
        obstacles.append(Obstacle(height: 12, width: 1, x: (GameBoard.BOARD_SIZE / 5) * 3, y: GameBoard.BOARD_SIZE / 3 + 12));
        obstacles.append(Obstacle(height: 1, width: 11, x: (GameBoard.BOARD_SIZE / 5) * 3, y: GameBoard.BOARD_SIZE / 3 + 1));
        obstacles.append(Obstacle(height: 1, width: 11, x: (GameBoard.BOARD_SIZE / 5) * 3 + 11, y: GameBoard.BOARD_SIZE / 3 + 1));
        movingObstacles.append(MovingObstacle(height: 2, width: 2, x: (GameBoard.BOARD_SIZE / 5) * 3 + 3, y: GameBoard.BOARD_SIZE / 3 + 8, xDir: -1, yDir: -1));
        
        movingObstacles.append(MovingObstacle(height: 6, width: 6, x: (GameBoard.BOARD_SIZE / 2 - 3), y: GameBoard.BOARD_SIZE / 2, xDir: 1, yDir: 1));
        obstacles.append(Obstacle(height: (GameBoard.BOARD_SIZE / 2), width: 1, x: GameBoard.BOARD_SIZE / 4, y: (GameBoard.BOARD_SIZE / 4) * 3 - 10));
        for i in 0..<10 {
            obstacles.append(Obstacle(height: 1, width: 1, x: GameBoard.BOARD_SIZE / 4 - i, y: (GameBoard.BOARD_SIZE / 4) * 3 - i - 10));
            obstacles.append(Obstacle(height: 1, width: 1, x: GameBoard.BOARD_SIZE / 4 + i + (GameBoard.BOARD_SIZE / 4) * 2, y: (GameBoard.BOARD_SIZE / 4) * 3 - i - 10));
        }
    }
}
