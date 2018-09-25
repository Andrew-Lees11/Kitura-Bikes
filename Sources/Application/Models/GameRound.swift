//
//  GrameRound.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation
import KituraWebSocket
import Dispatch

public class GameRound {
    public enum State: String, Codable {
        case OPEN // not yet started, still room for players
        case FULL // not started, but no more room for players
        case STARTING // in the process of game starting countdown
        case RUNNING // game is in progress and players are still alive
        case FINISHED // game has ended and a winner has been declared
    }
    
    private static let GAME_TICK_SPEED_DEFAULT = 50 // ms
    private static let DELAY_BETWEEN_ROUNDS = 5 //ticks
    private static let STARTING_COUNTDOWN = 4 // seconds
    private static let MAX_TIME_BETWEEN_ROUNDS_DEFAULT = 20 // seconds
    private static let FULL_GAME_TIME_BETWEEN_ROUNDS = 5 //seconds
    
    private static var runningGames: Int = 0
    
    // Properties exposed in JSON representation of object
    public let id: String
    public let nextRoundId: String
    public var gameState: State = State.OPEN;
    public let board = GameBoard(map: -1);
    
    private var gameRunning: Bool = false
    private var paused: Bool = false
    private var heartbeatStarted: Bool = false
    private var clients = [String: Client]()
    private var playerRanks: [Player] = []
    //private final Set<LifecycleCallback> lifecycleCallbacks = new HashSet<>();
    private let GAME_TICK_SPEED: Int = GAME_TICK_SPEED_DEFAULT
    private var MAX_TIME_BETWEEN_ROUNDS: Int = MAX_TIME_BETWEEN_ROUNDS_DEFAULT
    //private LobbyCountdown lobbyCountdown;
    private var lobbyCountdownStarted: Bool = false
    private var ticksFromGameEnd = 0
    private let encoder = JSONEncoder()
    
    // Get a string of 4 random uppercase letters (A-Z)
    private static func getRandomId() -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<4 {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
    
    public convenience init() {
        self.init(id: GameRound.getRandomId());
    }
    
    public init(id: String) {
        self.id = id;
        nextRoundId = GameRound.getRandomId();
    }
    
    private func beginLobbyCountdown(session: WebSocketConnection , isPhone: Bool) {
        if (!lobbyCountdownStarted) {
            lobbyCountdownStarted = true
        }
        if (!isPhone) {
            let _ = try? session.send(message: encoder.encode(OutboundMessage.AwaitPlayersCountdown(remainingPlayerAwaitTime: MAX_TIME_BETWEEN_ROUNDS)))
        }
    }
    
    public func updatePlayerDirection(session: WebSocketConnection, msg: InboundMessage) {
        let client = clients[session.id]
        if let player = client?.player {
            player.setDirection(newDirection: msg.direction)
        }
    }
    
    public func addPlayer(session: WebSocketConnection, playerId: String, playerName: String, hasGameBoard: Bool) -> Bool {
        // Front end should be preventing a player joining a full game but
        // defensive programming
        if (!isOpen()) {
            print("Cannot add player " + playerId + " to game because game has already started.")
            return false
        }
    
        if playerId.isEmpty {
            print("Player must have a valid ID to join a round, but was null/empty.");
            return false;
        }
        
        for client in clients.values {
            if let player = client.player, playerId == player.id {
                print("Cannot add player " + playerId + " to game because a player with that ID is already in the game.");
                return false;
            }
        
            if board.players.count + 1 >= Player.MAX_PLAYERS {
                gameState = State.FULL
                gameFull()
            }
            
            let player = board.addPlayer(playerId: playerId, playerName: playerName)
            if let player = player {
                let client = Client(webSocketConnection: session, player: player, autoRequeue: false)
                client.isPhone = !hasGameBoard
                clients[client.session.id] = client
                print("Player " + playerId + " has joined.")
            } else {
                print("Player " + playerId + " already exists.")
            }
            broadcastPlayerList()
            broadcastGameBoard()
            beginHeartbeat()
            beginLobbyCountdown(session: session, isPhone: client.isPhone)
        }
        return true
    }
    
    public func addAI() {
        if (!isOpen()) {
            return
        }
        
        if (board.players.count + 1 >= Player.MAX_PLAYERS) {
            gameState = State.FULL;
        }
        
        board.addAI();
        broadcastPlayerList();
        broadcastGameBoard();
    }
    
    public func addSpectator(session: WebSocketConnection) {
        print("A spectator has joined.")
        clients[session.id] = Client(webSocketConnection: session)
        do {
            try session.send(message: encoder.encode(OutboundMessage.PlayerList(players: board.players)))
            try session.send(message: encoder.encode(board))
        } catch {
            print("failed to encode to json")
        }
        beginHeartbeat();
        beginLobbyCountdown(session: session, isPhone: false);
    }
    
//    public func addCallback(callback: LifecycleCallback) {
//        LifecycleCallback.add(callback);
//    }
    
    private func beginHeartbeat() {
        
    }
    
    public func isPlayer(session: WebSocketConnection) -> Bool {
        let client = clients[session.id]
        return client?.player != nil
    }
    
    private func removePlayer(p: Player) {
        p.disconnect();
        print(p.name + " disconnected.");
    
        // Open player slot for new joiners
        if gameState == State.FULL, board.players.count - 1 < Player.MAX_PLAYERS {
            gameState = State.OPEN;
        }
    
        if (isOpen()) {
            let _ = board.removePlayer(p)
        } else if (gameState == State.RUNNING) {
            checkForWinner()
        }
        
        if (gameState != State.FINISHED) {
            broadcastPlayerList()
        }
    }
    
    public func removeClient(session: WebSocketConnection) -> Int {
        if let client = clients[session.id], let player = client.player {
            removePlayer(p: player)
        }
        return clients.count
    }
    
//    public func getPlayers() -> Set<Player> {
//        return board.players
//    }
    
    public func run() {
        gameRunning = true
        print(">>> Starting round");
        ticksFromGameEnd = 0;
        GameRound.runningGames += 1
        let numGames = GameRound.runningGames
        if (numGames > 3) {
            print("WARNING: There are currently " + String(numGames) + " game instances running.");
        }
        var nextTick = Date().addingTimeInterval(Double(GAME_TICK_SPEED) * 0.001)
        
        while (gameRunning) {
            delayTo(wakeUpTime: nextTick)
            nextTick = nextTick.addingTimeInterval(Double(GAME_TICK_SPEED) * 0.001)
            gameTick()
            if (ticksFromGameEnd > GameRound.DELAY_BETWEEN_ROUNDS) {
                gameRunning = false // end the game if nobody can move anymore
            }
        }
        endGame()
    }
    
    private func updatePlayerStats() {
        if (gameState != State.FINISHED) {
            print("Canot update player stats while game is still running.")
        }
        //PlayerService playerSvc = CDI.current().select(PlayerService.class, RestClient.LITERAL).get();
        var rank = 1
        for p in playerRanks {
            print("Player \(p.name) came in place \(rank)")
            if (p.isRealPlayer()) {
                //playerSvc.recordGame(p.id, rank)
                rank += 1
            }
        }
    }
    
    private func gameTick() {
        if (gameState != State.RUNNING) {
            ticksFromGameEnd += 1
            return;
        }
    
        board.broadcastToAI();
        
        let boardUpdated = board.moveObjects()
        var playerDied = false
        var playersMoved = false
        // Move all living players forward 1
        for player in board.players {
            if player.isAlive {
                if (player.movePlayer(board: &board.board)) {
                    playersMoved = true
                } else {
                    playerDied = true
                    playerRanks.append(player)
                }
            }
        }
        
        if playerDied {
            checkForWinner()
        }
        if playersMoved || boardUpdated {
            broadcastGameBoard()
        }
        if playerDied {
            broadcastPlayerList()
        }
    }
    
    private func delayTo(wakeUpTime: Date) {
        Thread.sleep(until: wakeUpTime)
    }
    
    // delay for ms milliseconds
    private func delay(_ ms: Int) {
        if ms < 0 {
            return
        }
        usleep(useconds_t(ms * 1000))
    }
    
    private func getNonMobileSessions() -> [WebSocketConnection] {
        return clients.values
            .filter { $0.isPhone }
            .map { $0.session }
    }
    
    private func broadcastTimeUntilGameStarts(time: Int) {
        for session in getNonMobileSessions() {
            let _ = try? session.send(message: encoder.encode(OutboundMessage.AwaitPlayersCountdown(remainingPlayerAwaitTime: time)))
        }
    }
    
    private func broadcastGameBoard() {
        for session in getNonMobileSessions() {
            let _ = try? session.send(message: encoder.encode(board))
        }
    }
    
    private func broadcastPlayerList() {
        for session in getNonMobileSessions() {
            let _ = try? session.send(message: encoder.encode(OutboundMessage.PlayerList(players: board.players)))
        }
    }
    
    private func checkForWinner() {
        if (board.players.count < 2) {// 1 player game, no winner
            gameState = State.FINISHED
            return
        }
        var alivePlayers = 0
        var alive: Player?
        for cur in board.players {
            if cur.isAlive {
                alivePlayers += 1
                alive = cur
            }
        }
        if (alivePlayers == 1) {
            alive?.setStatus(newState: .Winner)
            playerRanks.append(alive!)
            gameState = State.FINISHED
        }
        
        if (alivePlayers == 0) {
        gameState = State.FINISHED;
        }
    }
    
    public func isStarted() -> Bool {
        return gameState != State.OPEN && gameState != State.FULL;
    }
    
    public func isOpen() -> Bool {
        return gameState == State.OPEN;
    }
    
    public func startGame() {
        if isStarted() {
            return;
        }
    
        while isOpen() {
            addAI()
        }
    
        // Issue a countdown to all of the clients
        gameState = .STARTING
        for client in clients.values {
            let _ = try? client.session.send(message: encoder.encode(OutboundMessage.StartingCountdown(startingSeconds: GameRound.STARTING_COUNTDOWN)))
        }
        delay(GameRound.STARTING_COUNTDOWN * 1000)
        
        paused = false
        for p in board.players {
            if .Connected == p.playerStatus {
                p.setStatus(newState: .Alive)
                broadcastPlayerList()
            }
            if !gameRunning {
//                ManagedScheduledExecutorService exec = executor();
//                if (exec != null)
//                exec.submit(this);
            }
        }
        gameState = State.RUNNING;
    }
    
    private func endGame() {
        GameRound.runningGames -= 1
        print("<<< Finished round");
        broadcastPlayerList();
        
//        ManagedScheduledExecutorService exec = executor();
//        if (exec != null) {
//        exec.submit(() -> {
//        updatePlayerStats();
//        });
//        exec.submit(() -> {
//        lifecycleCallbacks.forEach(c -> c.gameEnding());
//        });
//        }
        
        // Tell each client that the game is done and close the websockets
        for client in clients.values {
            let _ = try? client.session.send(message: encoder.encode(OutboundMessage.GameStatus(gameStatus: State.FINISHED.rawValue)))
            //sendToClient(s, new OutboundMessage.GameStatus(State.FINISHED));
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            for client in self.clients.values {
                let _ = self.removeClient(session: client.session)
            }
        }
    }
    
//    private ManagedScheduledExecutorService executor() {
//    try {
//    return InitialContext.doLookup("java:comp/DefaultManagedScheduledExecutorService");
//    } catch (NamingException e) {
//    log("Unable to obtain ManagedScheduledExecutorService");
//    e.printStackTrace();
//    return null;
//    }
//    }
//
    private func log(msg: String) {
        print("[GameRound- \(id) + ]  \(msg)");
    }
    
    
    public func gameFull() {
        MAX_TIME_BETWEEN_ROUNDS = MAX_TIME_BETWEEN_ROUNDS > 5 ? GameRound.FULL_GAME_TIME_BETWEEN_ROUNDS : MAX_TIME_BETWEEN_ROUNDS
        broadcastTimeUntilGameStarts(time: MAX_TIME_BETWEEN_ROUNDS)
    }

    public func lobbyCountdownRun() {
        while isOpen() || gameState == State.FULL {
            delay(1000);
            MAX_TIME_BETWEEN_ROUNDS -= 1
            if (MAX_TIME_BETWEEN_ROUNDS < 1) {
                if (clients.count == 0) {
                    print("No clients remaining.  Cancelling LobbyCountdown.")
                    // Ensure that game state is closed off so that no other players can quick join while a round is marked for deletion
                    gameState = State.FINISHED
                } else {
                    startGame()
                }
            }
        }
    }

//    private class HeartbeatTrigger implements Trigger {
//
//    private static final int HEARTBEAT_INTERVAL_SEC = 100;
//
//    @Override
//    public Date getNextRunTime(LastExecution lastExecutionInfo, Date taskScheduledTime) {
//    // If there are any clients still connected to this game, keep sending heartbeats
//    if (clients.size() == 0) {
//    log("No clients remaining.  Cancelling heartbeat.");
//    // Ensure that game state is closed off so that no other players can quick join while a round is marked for deletion
//    gameState = State.FINISHED;
//    return null;
//    }
//    return Date.from(Instant.now().plusSeconds(HEARTBEAT_INTERVAL_SEC));
//    }
//
//    @Override
//    public boolean skipRun(LastExecution lastExecutionInfo, Date scheduledRunTime) {
//    return clients.size() == 0;
//    }
//
//    }
}

public protocol LifecycleCallback {
    func gameEnding()
}
