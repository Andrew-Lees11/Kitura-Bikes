//
//  OriginalMap.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

public class OriginalMap: GameMap {
    
    public override init() {
        super.init()
        movingObstacles.append(MovingObstacle(height: 5, width: 5, x: GameBoard.BOARD_SIZE / 2 - 10, y: GameBoard.BOARD_SIZE / 3, xDir: -1, yDir: -1))
        movingObstacles.append(MovingObstacle(height: 5, width: 5, x: GameBoard.BOARD_SIZE / 2 + 10, y: (GameBoard.BOARD_SIZE / 3 * 2) - 5, xDir: 1, yDir: 1))
        
        // Creating some walls
        // TopLeft
        obstacles.append(Obstacle(height: 15, width: 1, x: GameBoard.BOARD_SIZE / 8, y: GameBoard.BOARD_SIZE / 8));
        obstacles.append(Obstacle(height: 1, width: 14, x: GameBoard.BOARD_SIZE / 8, y: GameBoard.BOARD_SIZE / 8 + 1));
        // TopRight
        obstacles.append(Obstacle(height: 15, width: 1, x: ((GameBoard.BOARD_SIZE / 8) * 7) - 14, y: GameBoard.BOARD_SIZE / 8));
        obstacles.append(Obstacle(height: 1, width: 14, x: (GameBoard.BOARD_SIZE / 8) * 7, y: GameBoard.BOARD_SIZE / 8 + 1));
        // BottomLeft
        obstacles.append(Obstacle(height: 15, width: 1, x: GameBoard.BOARD_SIZE / 8, y: (GameBoard.BOARD_SIZE / 8) * 7));
        obstacles.append(Obstacle(height: 1, width: 14, x: GameBoard.BOARD_SIZE / 8, y: ((GameBoard.BOARD_SIZE / 8) * 7) - 14));
        // BottomRight
        obstacles.append(Obstacle(height: 15, width: 1, x: ((GameBoard.BOARD_SIZE / 8) * 7) - 14, y: (GameBoard.BOARD_SIZE / 8) * 7));
        obstacles.append(Obstacle(height: 1, width: 14, x: (GameBoard.BOARD_SIZE / 8) * 7, y: ((GameBoard.BOARD_SIZE / 8) * 7) - 14));
    }
    
    public required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
