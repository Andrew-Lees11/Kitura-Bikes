/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

// KituraChatServer is a very simple chat server
import Dispatch
import Foundation
import LoggerAPI
import KituraWebSocket

public class GameRoundWebsocket: WebSocketService {
    public func connected(connection: WebSocketConnection) {
        Log.verbose("Websocket session connected. id: \(connection.id)")
    }
    
    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        Log.verbose("Websocket session disconnected. id: \(connection.id)")
    }
    
    public func received(message: Data, from: WebSocketConnection) {
        
    }
    
    public func received(message: String, from: WebSocketConnection) {
        
    }
    
}
