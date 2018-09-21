//
//  Player.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class Player: Codable, Hashable {
    public var hashValue: Int
    
    public enum STATUS: String, Codable {
        case Connected
        case Alive
        case Dead
        case Winner
        case Disconnected
    }
    
    public static let PLAYER_SIZE = 3; // 3x3 squares
    public static let PLAYER_COLORS = [ "#ABD155", "#6FC3DF", "#c178c9", "#f28415" ]; // green, blue, purple, orange
    public static let MAX_PLAYERS = PLAYER_COLORS.count;
    
    // Properties exposed by JSON-B
    public let name: String
    public let id: String
    public let color: String
    public var x = 0
    public var y = 0
    public let width = PLAYER_SIZE, height = PLAYER_SIZE;
    public var isAlive = true;
    public var playerStatus = STATUS.Connected;
    
    public let playerNum: Int
    var direction: DIRECTION
    private var directionLastTick: [DIRECTION]
    private var desiredNextDirection: DIRECTION?
    
    public var ai: AI?
    
    private var trail: [TrailPosition]
    
    private struct TrailPosition: Codable, Hashable {
        public let x: Int
        public let y: Int
    }
    
    public init?(id: String, name: String, playerNum: Int) {
        self.id = id
        self.name = name
        self.playerNum = playerNum
    
    // Initialize starting data
        if playerNum >= Player.MAX_PLAYERS || playerNum < 0 {
            return nil
        }
        self.color = Player.PLAYER_COLORS[playerNum];
    }
    
    public func getDirection() -> DIRECTION {
        return desiredNextDirection ?? direction
    }
    
    public func setDirection(newDirection: DIRECTION) {
        guard isAlive || newDirection != direction else {
            return
        }
    
    
        // Make sure the player doesn't move backwards on themselves
        if directionLastTick.indices.contains(0) {
            if newDirection.isOppositeOf(dir: directionLastTick[0]) || newDirection.isOppositeOf(dir: directionLastTick[1]) {
            desiredNextDirection = newDirection
            return
            }
        }
        direction = newDirection
    }
    
    /**
     * Move a player forward one space in whatever direction they are facing currently.
     *
     * @return True if the player is still alive after moving forward one space. False otherwise.
     */
    public func movePlayer(board: inout [[Int]]) -> Bool {
    // If a player issues two moves in the same game tick and the second direction would kill themselves,
    // spread out the moves across 2-3 ticks rather than ignoring the second move entirely
        if let newDirection = desiredNextDirection,
               directionLastTick[0] == direction,
               directionLastTick[1] == direction
        {
            setDirection(newDirection: newDirection);
            desiredNextDirection = nil
        }
    
    switch (direction) {
        case .UP:
            if (y - 1 < 0 || checkCollision(board: board, x: x, y: y - 1)) {
                setStatus(newState: STATUS.Dead)
                return isAlive
            }
            moveUp(board: &board);
            break
        case .DOWN:
            if (y + height + 1 >= GameBoard.BOARD_SIZE || checkCollision(board: board, x: x, y: y + 1)) {
            setStatus(newState: STATUS.Dead)
            return isAlive
            }
            moveDown(board: &board)
            break
        case .RIGHT:
            if (x + width + 1 >= GameBoard.BOARD_SIZE || checkCollision(board: board, x: x + 1, y: y)) {
            setStatus(newState: STATUS.Dead);
            return isAlive
            }
            moveRight(board: &board);
            break
        case .LEFT:
            if (x - 1 < 0 || checkCollision(board: board, x: x - 1, y: y)) {
            setStatus(newState: STATUS.Dead);
            return isAlive
            }
            moveLeft(board: &board)
            break
        }
    
        trail.append(TrailPosition(x: x + 1, y: y + 1));
        var first = true;
        if (trail.count > 2) {
            for (index, _) in trail.enumerated() {
                if index < trail.count {
                    let trailPoint = trail[index + 1]
                    if !withinOneSquare(trail: trailPoint){
                        if first {
                            board[trailPoint.x][trailPoint.y] = GameBoard.TRAIL_SPOT_TAKEN
                            first = false
                        } else {
                            board[trailPoint.x][trailPoint.y] = GameBoard.TRAIL_SPOT_TAKEN
                            break
                        }
                    }
                }
            }
        }
    
    directionLastTick[1] = directionLastTick[0]
    directionLastTick[0] = direction
    
    return isAlive
    }
    
    private func withinOneSquare(trail: TrailPosition) -> Bool {
        if abs(trail.x - (x + 1)) <= 1 && abs(trail.y - (y + 1)) <= 1 {
            return true
        }
        return false
    }
    
    private func checkCollision(board: [[Int]], x: Int, y: Int) -> Bool {
        for i in 0..<width {
            for j in 0..<height {
                if !(board[x + i][y + j] == GameBoard.PLAYER_SPOT_TAKEN + playerNum || board[x + i][y + j] == GameBoard.SPOT_AVAILABLE) {
                    return true
                }
            }
        }
        return false;
    }
    
    private func moveRight(board: inout [[Int]]) {
        for i in 0..<height {
            // clear previous position
            board[x][y + i] = GameBoard.SPOT_AVAILABLE
            board[x + width][y + i] += GameBoard.PLAYER_SPOT_TAKEN + playerNum
        }
        x += 1
    }
    
    private func moveLeft(board: inout [[Int]]) {
        for i in 0..<height {
        board[x - 1][y + i] += GameBoard.PLAYER_SPOT_TAKEN + playerNum
        board[x + width - 1][y + i] = GameBoard.SPOT_AVAILABLE
        }
        x -= 1
    }
    
    private func moveUp(board: inout [[Int]]) {
        for i in 0..<width {
            board[x + i][y - 1] += GameBoard.PLAYER_SPOT_TAKEN + playerNum
            board[x + i][y + height - 1] = GameBoard.SPOT_AVAILABLE
        }
        y -= 1
    }
    
    private func moveDown(board: inout [[Int]]) {
        for i in 0..<width {
            board[x + i][y] = GameBoard.SPOT_AVAILABLE
            board[x + i][y + height] += GameBoard.PLAYER_SPOT_TAKEN + playerNum
        }
        y += 1
    }
    
    public func disconnect() {
        setStatus(newState: STATUS.Disconnected);
    }
    
    public func setStatus(newState: STATUS) {
        if (newState == STATUS.Dead || newState == STATUS.Disconnected) {
            self.isAlive = false
        }
        if (newState == STATUS.Dead && self.playerStatus == STATUS.Winner) {
            return; // Winning player can't die (game is over)
        }
        self.playerStatus = newState
    }
    
    public func isRealPlayer() -> Bool {
        return ai == nil
    }
    
    public func processAIMove(board: [[Int]]) {
        guard let ai = ai else {
            return
        }
        direction = ai.processGameTick(board: board);
    }
    
    public func addTo(map: GameMap) -> Player {
        self.x = map.startingPoints[playerNum].x;
        self.y = map.startingPoints[playerNum].y;
        self.direction = map.startingDirections[playerNum]
        return self;
    }
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.name == rhs.name &&
            lhs.id == rhs.id &&
            lhs.color == rhs.color &&
            lhs.x == rhs.x &&
            lhs.y == rhs.y &&
            lhs.width == rhs.width &&
            lhs.isAlive == rhs.isAlive &&
            lhs.playerStatus == rhs.playerStatus &&
            lhs.playerNum == rhs.playerNum &&
            lhs.direction == rhs.direction &&
            lhs.directionLastTick == rhs.directionLastTick &&
            lhs.desiredNextDirection == rhs.desiredNextDirection &&
            lhs.ai == rhs.ai &&
            lhs.trail == rhs.trail
    }
    
}
