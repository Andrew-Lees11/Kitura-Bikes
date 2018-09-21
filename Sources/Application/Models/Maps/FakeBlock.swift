//
//  FakeBlock.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class FakeBlock: GameMap {
    
    public override init() {
        let size = 4
        let offset = 2
        let speed = 2
        movingObstacles.append(MovingObstacle(height: size, width: size, x: GameBoard.BOARD_SIZE / 2 - size - offset, y: GameBoard.BOARD_SIZE / 2 - size - offset, xDir: -1, yDir: -1, moveDelay: speed));
        movingObstacles.append(MovingObstacle(height: size, width: size, x: GameBoard.BOARD_SIZE / 2 - offset, y: GameBoard.BOARD_SIZE / 2 - size - offset, xDir: 0, yDir: -1, moveDelay: speed));
        movingObstacles.append(MovingObstacle(height: size, width: size, x: GameBoard.BOARD_SIZE / 2 + size - offset, y: GameBoard.BOARD_SIZE / 2 - size - offset, xDir: 1, yDir: -1, moveDelay: speed));
        movingObstacles.append(MovingObstacle(height: size, width: size, x: GameBoard.BOARD_SIZE / 2 - size - offset, y: GameBoard.BOARD_SIZE / 2 - offset, xDir: -1, yDir: 0, moveDelay: speed));
        obstacles.append(Obstacle(height: size, width: size, x: GameBoard.BOARD_SIZE / 2 - offset, y: GameBoard.BOARD_SIZE / 2 - offset));
        movingObstacles.append(MovingObstacle(height: size, width: size, x: GameBoard.BOARD_SIZE / 2 + size - offset, y: GameBoard.BOARD_SIZE / 2 - offset, xDir: 1, yDir: 0, moveDelay: speed));
        movingObstacles.append(MovingObstacle(height: size, width: size, x: GameBoard.BOARD_SIZE / 2 - size - offset, y: GameBoard.BOARD_SIZE / 2 + size - offset, xDir: -1, yDir: 1, moveDelay: speed));
        movingObstacles.append(MovingObstacle(height: size, width: size, x: GameBoard.BOARD_SIZE / 2 - offset, y: GameBoard.BOARD_SIZE / 2 + size - offset, xDir: 0, yDir: 1, moveDelay: speed));
        movingObstacles.append(MovingObstacle(height: size, width: size, x: GameBoard.BOARD_SIZE / 2 + size - offset, y: GameBoard.BOARD_SIZE / 2 + size - offset, xDir: 1, yDir: 1, moveDelay: speed));
    }
}
