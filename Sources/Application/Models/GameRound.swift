//
//  GrameRound.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation
import KituraWebSocket

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
    public let board = GameBoard(map: -1);
    
    private var gameRunning: Bool
    private var paused: Bool
    private var heartbeatStarted: Bool
    //private final Map<Session, Client> clients = new HashMap<>();
    private var playerRanks: [Player]
    //private final Set<LifecycleCallback> lifecycleCallbacks = new HashSet<>();
    private let GAME_TICK_SPEED: Int
    private let MAX_TIME_BETWEEN_ROUNDS: Int
    //private LobbyCountdown lobbyCountdown;
    private var lobbyCountdownStarted: Bool
    private var ticksFromGameEnd = 0
    
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
            sendToClient(session, new OutboundMessage.AwaitPlayersCountdown(lobbyCountdown.roundStartCountdown));
        }
    }
    
    public void updatePlayerDirection(Session playerSession, InboundMessage msg) {
    Client c = clients.get(playerSession);
    c.player.ifPresent((p) -> p.setDirection(msg.direction));
    }
    
    public boolean addPlayer(Session s, String playerId, String playerName, Boolean hasGameBoard) {
    // Front end should be preventing a player joining a full game but
    // defensive programming
    if (!isOpen()) {
    log("Cannot add player " + playerId + " to game because game has already started.");
    return false;
    }
    
    if (playerId == null || playerId.isEmpty()) {
    log("Player must have a valid ID to join a round, but was null/empty.");
    return false;
    }
    
    for (Client c : clients.values())
    if (c.player.isPresent() && playerId.equals(c.player.get().id)) {
    log("Cannot add player " + playerId + " to game because a player with that ID is already in the game.");
    return false;
    }
    
    if (getPlayers().size() + 1 >= Player.MAX_PLAYERS) {
    gameState = State.FULL;
    lobbyCountdown.gameFull();
    }
    
    Player p = board.addPlayer(playerId, playerName);
    boolean isPhone = false;
    if (p != null) {
    Client c = new Client(s, p);
    isPhone = c.isPhone = hasGameBoard ? false : true;
    clients.put(s, c);
    log("Player " + playerId + " has joined.");
    } else {
    log("Player " + playerId + " already exists.");
    }
    broadcastPlayerList();
    broadcastGameBoard();
    beginHeartbeat();
    beginLobbyCountdown(s, isPhone);
    return true;
    }
    
    public void addAI() {
    if (!isOpen()) {
    return;
    }
    
    if (getPlayers().size() + 1 >= Player.MAX_PLAYERS) {
    gameState = State.FULL;
    }
    
    board.addAI();
    broadcastPlayerList();
    broadcastGameBoard();
    }
    
    public void addSpectator(Session s) {
    log("A spectator has joined.");
    clients.put(s, new Client(s));
    sendToClient(s, new OutboundMessage.PlayerList(getPlayers()));
    sendToClient(s, board);
    beginHeartbeat();
    beginLobbyCountdown(s, false);
    }
    
    public void addCallback(LifecycleCallback callback) {
    lifecycleCallbacks.add(callback);
    }
    
    private void beginHeartbeat() {
    // Send a heartbeat to connected clients every 100 seconds in an attempt to keep them connected.
    // It appears that when running in IBM Cloud, sockets time out after 120 seconds
    if (!heartbeatStarted.getAndSet(true)) {
    ManagedScheduledExecutorService exec = executor();
    if (exec != null) {
    log("Initiating heartbeat to clients");
    exec.schedule(() -> {
    log("Sending heartbeat to " + clients.size() + " clients");
    sendToClients(clients.keySet(), new OutboundMessage.Heartbeat());
    }, new HeartbeatTrigger());
    }
    }
    }
    
    @JsonbTransient
    public boolean isPlayer(Session s) {
    Client c = clients.get(s);
    return c != null && c.player.isPresent();
    }
    
    private void removePlayer(Player p) {
    p.disconnect();
    log(p.name + " disconnected.");
    
    // Open player slot for new joiners
    if (gameState == State.FULL && getPlayers().size() - 1 < Player.MAX_PLAYERS) {
    gameState = State.OPEN;
    }
    
    if (isOpen()) {
    board.removePlayer(p);
    } else if (gameState == State.RUNNING) {
    checkForWinner();
    }
    
    if (gameState != State.FINISHED)
    broadcastPlayerList();
    }
    
    public int removeClient(Session client) {
    Client c = clients.remove(client);
    if (c != null && c.player.isPresent())
    removePlayer(c.player.get());
    return clients.size();
    }
    
    @JsonbTransient
    public Set<Player> getPlayers() {
    return board.players;
    }
    
    @Override
    public void run() {
    gameRunning.set(true);
    log(">>> Starting round");
    ticksFromGameEnd = 0;
    int numGames = runningGames.incrementAndGet();
    if (numGames > 3)
    log("WARNING: There are currently " + numGames + " game instances running.");
    long nextTick = System.currentTimeMillis() + GAME_TICK_SPEED;
    while (gameRunning.get()) {
    delayTo(nextTick);
    nextTick += GAME_TICK_SPEED;
    gameTick();
    if (ticksFromGameEnd > DELAY_BETWEEN_ROUNDS)
    gameRunning.set(false); // end the game if nobody can move anymore
    }
    endGame();
    }
    
    private void updatePlayerStats() {
    if (gameState != State.FINISHED)
    throw new IllegalStateException("Canot update player stats while game is still running.");
    
    PlayerService playerSvc = CDI.current().select(PlayerService.class, RestClient.LITERAL).get();
    int rank = 1;
    for (Player p : playerRanks) {
    log("Player " + p.name + " came in place " + rank);
    if (p.isRealPlayer())
    playerSvc.recordGame(p.id, rank);
    rank++;
    }
    }
    
    private void gameTick() {
    if (gameState != State.RUNNING) {
    ticksFromGameEnd++;
    return;
    }
    
    board.broadcastToAI();
    
    boolean boardUpdated = board.moveObjects();
    boolean playerDied = false;
    boolean playersMoved = false;
    // Move all living players forward 1
    for (Player p : getPlayers()) {
    if (p.isAlive()) {
    if (p.movePlayer(board.board)) {
    playersMoved = true;
    } else {
    playerDied = true;
    playerRanks.push(p);
    }
    }
    }
    
    if (playerDied)
    checkForWinner();
    if (playersMoved || boardUpdated)
    broadcastGameBoard();
    if (playerDied)
    broadcastPlayerList();
    }
    
    private void delayTo(long wakeUpTime) {
    delay(wakeUpTime - System.currentTimeMillis());
    }
    
    private void delay(long ms) {
    if (ms < 0)
    return;
    try {
    Thread.sleep(ms);
    } catch (InterruptedException ie) {
    }
    }
    
    private Set<Session> getNonMobileSessions() {
    return clients.entrySet()
    .stream()
    .filter(c -> !c.getValue().isPhone)
    .map(s -> s.getKey())
    .collect(Collectors.toSet());
    }
    
    private void broadcastTimeUntilGameStarts(int time) {
    sendToClients(getNonMobileSessions(), new OutboundMessage.AwaitPlayersCountdown(time));
    }
    
    private void broadcastGameBoard() {
    sendToClients(getNonMobileSessions(), board);
    }
    
    private void broadcastPlayerList() {
    sendToClients(getNonMobileSessions(), new OutboundMessage.PlayerList(getPlayers()));
    }
    
    private void checkForWinner() {
    if (getPlayers().size() < 2) {// 1 player game, no winner
    gameState = State.FINISHED;
    return;
    }
    int alivePlayers = 0;
    Player alive = null;
    for (Player cur : getPlayers()) {
    if (cur.isAlive()) {
    alivePlayers++;
    alive = cur;
    }
    }
    if (alivePlayers == 1) {
    alive.setStatus(STATUS.Winner);
    playerRanks.push(alive);
    gameState = State.FINISHED;
    }
    
    if (alivePlayers == 0) {
    gameState = State.FINISHED;
    }
    }
    
    @JsonbTransient
    public boolean isStarted() {
    return gameState != State.OPEN && gameState != State.FULL;
    }
    
    @JsonbTransient
    public boolean isOpen() {
    return gameState == State.OPEN;
    }
    
    public void startGame() {
    if (isStarted())
    return;
    
    while (isOpen()) {
    addAI();
    }
    
    // Issue a countdown to all of the clients
    gameState = State.STARTING;
    
    sendToClients(clients.keySet(), new OutboundMessage.StartingCountdown(STARTING_COUNTDOWN));
    delay(TimeUnit.SECONDS.toMillis(STARTING_COUNTDOWN));
    
    paused.set(false);
    for (Player p : getPlayers())
    if (STATUS.Connected == p.getStatus())
    p.setStatus(STATUS.Alive);
    broadcastPlayerList();
    if (!gameRunning.get()) {
    ManagedScheduledExecutorService exec = executor();
    if (exec != null)
    exec.submit(this);
    }
    gameState = State.RUNNING;
    }
    
    private void endGame() {
    runningGames.decrementAndGet();
    log("<<< Finished round");
    broadcastPlayerList();
    
    ManagedScheduledExecutorService exec = executor();
    if (exec != null) {
    exec.submit(() -> {
    updatePlayerStats();
    });
    exec.submit(() -> {
    lifecycleCallbacks.forEach(c -> c.gameEnding());
    });
    }
    
    // Tell each client that the game is done and close the websockets
    for (Session s : clients.keySet())
    sendToClient(s, new OutboundMessage.GameStatus(State.FINISHED));
    
    // Give players a 10s grace period before they are removed from a finished game
    if (exec != null)
    exec.schedule(() -> {
    for (Session s : clients.keySet())
    removeClient(s);
    }, 10, TimeUnit.SECONDS);
    }
    
    private ManagedScheduledExecutorService executor() {
    try {
    return InitialContext.doLookup("java:comp/DefaultManagedScheduledExecutorService");
    } catch (NamingException e) {
    log("Unable to obtain ManagedScheduledExecutorService");
    e.printStackTrace();
    return null;
    }
    }
    
    private void log(String msg) {
    System.out.println("[GameRound-" + id + "]  " + msg);
    }
    
    public interface LifecycleCallback {
    public void gameEnding();
    }
    
    private class LobbyCountdown implements Runnable {
    
    public int roundStartCountdown = MAX_TIME_BETWEEN_ROUNDS;
    
    public void gameFull() {
    roundStartCountdown = roundStartCountdown > 5 ? FULL_GAME_TIME_BETWEEN_ROUNDS : roundStartCountdown;
    broadcastTimeUntilGameStarts(roundStartCountdown);
    }
    
    @Override
    public void run() {
    while (isOpen() || gameState == State.FULL) {
    delay(1000);
    roundStartCountdown--;
    if (roundStartCountdown < 1) {
    if (clients.size() == 0) {
    log("No clients remaining.  Cancelling LobbyCountdown.");
    // Ensure that game state is closed off so that no other players can quick join while a round is marked for deletion
    gameState = State.FINISHED;
    } else {
    startGame();
    }
    }
    }
    }
    }
    
    private class HeartbeatTrigger implements Trigger {
    
    private static final int HEARTBEAT_INTERVAL_SEC = 100;
    
    @Override
    public Date getNextRunTime(LastExecution lastExecutionInfo, Date taskScheduledTime) {
    // If there are any clients still connected to this game, keep sending heartbeats
    if (clients.size() == 0) {
    log("No clients remaining.  Cancelling heartbeat.");
    // Ensure that game state is closed off so that no other players can quick join while a round is marked for deletion
    gameState = State.FINISHED;
    return null;
    }
    return Date.from(Instant.now().plusSeconds(HEARTBEAT_INTERVAL_SEC));
    }
    
    @Override
    public boolean skipRun(LastExecution lastExecutionInfo, Date scheduledRunTime) {
    return clients.size() == 0;
    }
    
    }
}
