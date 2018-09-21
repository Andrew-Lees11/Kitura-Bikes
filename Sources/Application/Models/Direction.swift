//
//  DIRECTION.swift
//  Application
//
//  Created by Andrew Lees on 21/09/2018.
//

public enum DIRECTION {
    case UP
    case DOWN
    case LEFT
    case RIGHT
    
    public static func opposite(dir: DIRECTION) -> DIRECTION {
        if (dir == UP) {
            return DOWN
        }
        if (dir == DOWN) {
            return UP
        }
        if (dir == LEFT) {
            return RIGHT
        }
        return LEFT;
    }
    
    public static func isOppositeOf(dir: DIRECTION) -> Bool {
        return this == DIRECTION.opposite(dir);
    }
}
