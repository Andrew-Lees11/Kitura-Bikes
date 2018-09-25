//
//  OutboundMessage.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

import Foundation

public class OutboundMessage: Codable {
    
    public class PlayerList: Codable {
        public let playerlist: [Player]
        
        public init(players: Set<Player>) {
            var tempList = [Player]()
            // Send players in proper order, padding out empty slots with "Bot Player"
            for player in players {
                tempList[player.playerNum] = player
            }
            for i in 0..<Player.MAX_PLAYERS {
                if tempList.indices.contains(i) {
                    tempList.append(Player(id: "", name: "BotPlayer", playerNum: i)!)
                }
            }
            self.playerlist = tempList
        }
    }
    
    public struct GameStatus: Codable {
        public let gameStatus: String
    }
    
    public struct RequeueGame: Codable {
        public let requeue: String
        
        public init(nextRoundId: String) {
            self.requeue = nextRoundId
        }
    }
    
    public struct StartingCountdown: Codable {
        public let countdown: Int
        
        public init(startingSeconds: Int) {
            self.countdown = startingSeconds;
        }
    }
    
    public struct AwaitPlayersCountdown: Codable {
        public let awaitplayerscountdown: Int
        
        public init(remainingPlayerAwaitTime: Int) {
            self.awaitplayerscountdown = remainingPlayerAwaitTime
        }
    }
    
    public struct Heartbeat: Codable {
        public let keepAlive = true
    }
    
    public struct QueuePosition: Codable {
        public let queuePosition: Int
        
        public init(pos: Int) {
            queuePosition = pos
        }
    }
    
    public struct ErrorEvent: Codable {
        public let errorMessage: String
        
        public init(errMsg: String) {
            self.errorMessage = errMsg;
        }
    }
    
}
