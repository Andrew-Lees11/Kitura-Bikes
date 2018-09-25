//
//  InboundMessage.swift
//  Application
//
//  Created by Andrew Lees on 22/09/2018.
//

import Foundation

public struct InboundMessage: Codable {
    
    public enum GameEvent: String, Codable {
        case GAME_START
        case GAME_REQUEUE
    }
    
    public let direction: DIRECTION
    
    public let playerjoined: String
    
    public let message: GameEvent
    
    public let spectatorjoined: Bool
    
    public let hasGameBoard: Bool
    
}
