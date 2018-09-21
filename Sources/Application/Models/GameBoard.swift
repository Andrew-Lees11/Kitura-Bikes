//
//  GameBoard.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

public class GameBoard {
    
    public static let BOARD_SIZE = 121
    public static let SPOT_AVAILABLE = 0, TRAIL_SPOT_TAKEN = -10, OBJECT_SPOT_TAKEN = -8, PLAYER_SPOT_TAKEN = 1
    private static var preferredPlayerSlots = [String: Int]()
    
    public class Point {
        public let x: Int
        public let y: Int
        
        public init?(x: Int, y: Int) {
            guard x < 0 || y < 0 || x >= BOARD_SIZE || y >= BOARD_SIZE else {
                return nil
            }
            self.x = x
            self.y = y
        }
    }
    
    var board = [[Int]]()
    
    public var obstacles: Set<Obstacle>
    public var movingObstacles: Set<MovingObstacle>
    public var players: Set<Player>
    private var takenPlayerSlots: [Bool]
    private let gameMap: GameMap
    
    
    public init(map: Int = -1) {
        for i in 0..<GameBoard.BOARD_SIZE {
            for j in 0..<GameBoard.BOARD_SIZE {
                board[i][j] = GameBoard.SPOT_AVAILABLE
            }
        }
        self.gameMap = GameMap.create(map: map)
        for o in gameMap.obstacles {
            let _ = addObstacle(o)
        }
        for o in gameMap.movingObstacles {
            let _ = addObstacle(o);
        }
    }
    
    public func verifyObstacle(_ o: Obstacle) -> Bool {
        if (o.x < 0 || o.y < 0 || o.x + o.width > GameBoard.BOARD_SIZE || o.y + o.height > GameBoard.BOARD_SIZE) {
            return false
        }
        // First make sure all spaces are available
        for x in 0..<o.width {
            for y in 0..<o.height {
                if (board[o.x + x][o.y + y] != GameBoard.SPOT_AVAILABLE) {
                    return false
                }
            }
        }
        // If all spaces are available, claim them
        for x in 0..<o.width {
            for y in 0..<o.height {
                board[o.x + x][o.y + y] = GameBoard.OBJECT_SPOT_TAKEN
                return true
            }
        }
    }
    
    public func addObstacle(_ o: Obstacle) -> Bool {
        return verifyObstacle(o) ? obstacles.insert(o).inserted : false;
    }
    
    public func addObstacle(o: MovingObstacle) -> Bool {
        return verifyObstacle(o) ? movingObstacles.insert(o).inserted : false;
    }
    
    public func addPlayer(playerId: String, playerName: String) -> Player? {
    
        var playerNum = -1
        
        // Try to keep players in the same slots across rounds if possible
        if let preferredSlot = GameBoard.preferredPlayerSlots[playerId],
               !takenPlayerSlots[preferredSlot]
        {
            playerNum = preferredSlot;
        } else {
            // Find first open player slot to fill, which determines position
            for i in 0..<takenPlayerSlots.count {
                if (!takenPlayerSlots[i]) {
                    playerNum = i;
                    break;
                }
            }
            GameBoard.preferredPlayerSlots[playerId] = playerNum
        }
        takenPlayerSlots[playerNum] = true
        
        // Don't let the preferred player slot map take up too much memory
        if (GameBoard.preferredPlayerSlots.count > 1000) {
            GameBoard.preferredPlayerSlots = [:]
        }
        
        // Initialize Player
        guard let p = Player(id: playerId, name: playerName, playerNum: playerNum)?.addTo(map: gameMap) else {
            return nil
        }
        
        if (p.x + p.width > GameBoard.BOARD_SIZE || p.y + p.height > GameBoard.BOARD_SIZE) {
            return nil
        }
        
        
        for i in 0..<p.width {
            for j in 0..<p.height {
                board[p.x + i][p.y + j] = GameBoard.PLAYER_SPOT_TAKEN + playerNum
            }
        }
        
        return players.insert(p).memberAfterInsert
    }
    
    public func removePlayer(_ p: Player) -> Bool {
        takenPlayerSlots[p.playerNum] = false
        
        // Right now we don't clear their dead body while drawing the canvas
        //        for (int i = 0; i < p.width; i++) {
        //            for (int j = 0; j < p.height; j++) {
        //                board[p.x + i][p.y + j] = SPOT_AVAILABLE;
        //            }
        //        }
        
        return players.remove(p) != nil
    }
    
    public func moveObjects() -> Bool {
        if movingObstacles.isEmpty {
            return false
        }
    
        for obstacle in movingObstacles {
            obstacle.checkCollision(board: board)
        }
        
        for obstacle in movingObstacles {
            obstacle.move(board: &board)
        }
        
        return true;
    }
    
    public func broadcastToAI() {
        for p in players {
            if p.isAlive {
                p.processAIMove(board: board)
            }
        }
    }
    
    public func addAI() {
        // Find first open player slot to fill, which determines position
        var playerNum = -1
        for i in 0 ..< takenPlayerSlots.count {
            if (!takenPlayerSlots[i]) {
                playerNum = i
                takenPlayerSlots[i] = true
                break
            }
        }
    
        // Initialize Player
        let ai = AI(map: gameMap, playerNum: playerNum).asPlayer()
        let npc = ai.addTo(map: gameMap)
        
        if (npc.x + npc.width > GameBoard.BOARD_SIZE || npc.y + npc.height > GameBoard.BOARD_SIZE) {
            print("Player does not fit on board: " + npc.id)
        }
        
        for i in 0 ..< npc.width {
            for j in 0 ..< npc.height {
                board[npc.x + i][npc.y + j] = GameBoard.PLAYER_SPOT_TAKEN + playerNum
            }
        }
        
        players.insert(npc)
    }
    
    public func removeAI(_ p: Player) -> Bool {
        takenPlayerSlots[p.playerNum] = false
        return players.remove(p) != nil
    }
    
}
