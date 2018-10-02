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
            return maps[Int(arc4random_uniform(UInt32(maps.count)))] ?? EmptyMap()
        } else {
            return maps[map] ?? EmptyMap()
        }
    }
    
    public var obstacles = [Obstacle]()
    public var movingObstacles = [MovingObstacle]()
    public var startingDirections = [DIRECTION.RIGHT, DIRECTION.DOWN, DIRECTION.UP, DIRECTION.LEFT]
    public var startingPoints: [GameBoard.Point] = [GameBoard.Point(x: 9, y: 9), GameBoard.Point(x: GameBoard.BOARD_SIZE - 11, y: 9), GameBoard.Point(x: 9, y: GameBoard.BOARD_SIZE - 11), GameBoard.Point(x: GameBoard.BOARD_SIZE - 11, y: GameBoard.BOARD_SIZE - 11)]
}
