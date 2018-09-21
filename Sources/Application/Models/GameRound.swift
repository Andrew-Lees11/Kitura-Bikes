//
//  GrameRound.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class GameRound {
    public enum State {
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
    private final GameBoard board = new GameBoard();
    
    private final AtomicBoolean gameRunning = new AtomicBoolean();
    private final AtomicBoolean paused = new AtomicBoolean();
    private final AtomicBoolean heartbeatStarted = new AtomicBoolean();
    private final Map<Session, Client> clients = new HashMap<>();
    private final Deque<Player> playerRanks = new ArrayDeque<>();
    private final Set<LifecycleCallback> lifecycleCallbacks = new HashSet<>();
    private final int GAME_TICK_SPEED, MAX_TIME_BETWEEN_ROUNDS;
    private LobbyCountdown lobbyCountdown;
    private AtomicBoolean lobbyCountdownStarted = new AtomicBoolean();
}
