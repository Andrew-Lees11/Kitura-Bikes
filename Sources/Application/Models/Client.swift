//
//  Client.swift
//  Application
//
//  Created by Andrew Lees on 22/09/2018.
//

import Foundation
import KituraWebSocket

public class Client {
    
    public let session: WebSocketConnection
    public let player: Player?
    public let autoRequeue: Bool
    public var isPhone = false
    
    
    public init(webSocketConnection: WebSocketConnection, player: Player? = nil, autoRequeue: Bool = false) {
        self.session = webSocketConnection
        self.player = player
        self.autoRequeue = autoRequeue
    }
    
}
