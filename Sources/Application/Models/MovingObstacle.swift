//
//  MovingObstacle.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class MovingObstacle: Obstacle {
    
    private var xDir: Int = 0
    private var yDir: Int = 0
    private var moveDelay: Int = 0
    private var currentDelay: Int = 0
    
    public init(height: Int, width: Int, x: Int, y: Int, xDir: Int, yDir: Int, moveDelay: Int = 1) {
        super.init(height: height, width: width, x: x, y: y)
        self.moveDelay = moveDelay;
        self.xDir = xDir;
        self.yDir = yDir;
    }
    
    required public init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func checkCollision(board: [[Int]]) {
        var checkCorner = true;
        
        if (xDir != 0) {
            if (xDir > 0) {
                if (x + width + 1 >= GameBoard.BOARD_SIZE || hasCollision(board: board, dir: DIRECTION.RIGHT)) {
                    xDir = xDir * -1;
                    checkCorner = false;
                }
            } else {
                if (x - 1 < 0 || hasCollision(board: board, dir: DIRECTION.LEFT)) {
                    xDir = xDir * -1;
                    checkCorner = false;
                }
            }
        }
        if (yDir != 0) {
            if (yDir > 0) {
                if (y + height + 1 >= GameBoard.BOARD_SIZE || hasCollision(board: board, dir: DIRECTION.DOWN)) {
                    yDir = yDir * -1;
                    checkCorner = false;
                }
            } else {
                if (y - 1 < 0 || hasCollision(board: board, dir: DIRECTION.UP)) {
                    yDir = yDir * -1;
                    checkCorner = false;
                }
            }
        }
        if (checkCorner) {
            checkCornerCollision(board: board);
        }
    }
    
    public func move(board: [[Int]]) {
        
        if (currentDelay + 1 < moveDelay) {
            // don't move yet
            return;
        }
        
        currentDelay = 0;
        
        for i in 0...width {
            for j in 0...height {
                board[x + i][y + j] = GameBoard.SPOT_AVAILABLE;
            }
        }
        for i in 0...width {
            for j in 0...height {
                board[x + i + xDir][y + j + yDir] = GameBoard.OBJECT_SPOT_TAKEN;
            }
        }
        x += xDir;
        y += yDir;
        
    }
    
    private func checkCornerCollision(board: [[Int]]) {
        if xDir == 0 || yDir == 0 {
            return;
        }
        if (xDir > 0) {
            if (yDir > 0 && board[x + width][y + height] == GameBoard.OBJECT_SPOT_TAKEN) {
                xDir = xDir * -1;
                yDir = yDir * -1;
            } else if (yDir < 0 && board[x + width][y - 1] == GameBoard.OBJECT_SPOT_TAKEN) {
                xDir = xDir * -1;
                yDir = yDir * -1;
            }
            
        } else {
            if (yDir > 0 && board[x - 1][y + height] == GameBoard.OBJECT_SPOT_TAKEN) {
                xDir = xDir * -1;
                yDir = yDir * -1;
            } else if (yDir < 0 && board[x - 1][y - 1] == GameBoard.OBJECT_SPOT_TAKEN) {
                xDir = xDir * -1;
                yDir = yDir * -1;
            }
            
        }
    }
    
    // loops through the spots we want to move to and see if they are already taken by
    // only another object, we will move through players and their lines
    private func hasCollision(board: [[Int]], dir: DIRECTION) -> Bool {
        switch (dir) {
            case .UP:
                for i in 0 ..< width {
                    if (board[x + i][y - 1] == GameBoard.OBJECT_SPOT_TAKEN) {
                        return true
                    }
                }
                return false;
            case .DOWN:
                for i in 0 ..< width {
                    if (board[x + i][y + height] == GameBoard.OBJECT_SPOT_TAKEN) {
                        return true
                    }
                }
                return false;
            case .LEFT:
                for i in 0 ..< height {
                    if (board[x - 1][y + i] == GameBoard.OBJECT_SPOT_TAKEN) {
                        return true
                    }
                }
                return false;
            case .RIGHT:
                for i in 0 ..< height {
                    if (board[x + width][y + i] == GameBoard.OBJECT_SPOT_TAKEN) {
                        return true
                    }
                }
        }
        return false;

    }
    
}
