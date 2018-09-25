//
//  GameMap.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//
import Foundation

public class GameMap: Codable {
    
    public static let maps: [Int: GameMap] =
        [0: EmptyMap(),
        1: OriginalMap(),
        2: CrossSlice(),
        3: FakeBlock(),
        4: Smile(),
        5: HulkSmash()]
    
    public static func create(map: Int) -> GameMap {
        if map >= 0 && map < maps.count {
            return maps[Int(arc4random_uniform(UInt32(maps.count)))]
        } else {
            return maps[map]
        }
    }
    
    public var obstacles = [Obstacle]()
    public var movingObstacles = [MovingObstacle]()
    public var startingDirections = [DIRECTION.RIGHT, DIRECTION.DOWN, DIRECTION.UP, DIRECTION.LEFT]
    public var startingPoints: [GameBoard.Point] = [Point(9, 9), Point(GameBoard.BOARD_SIZE - 11, 9), Point(9, GameBoard.BOARD_SIZE - 11), Point(GameBoard.BOARD_SIZE - 11, GameBoard.BOARD_SIZE - 11)]
}
