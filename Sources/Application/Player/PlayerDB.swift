import Foundation

public class PlayerDB {
    
    // TODO back this by a DB instead of in-mem
    private var allPlayers = [String: Player]()
    
    /**
     * Inserts a new player into the database.
     *
     * @return Returns true if the player was created. False if a player with the same ID already existed
     */
    public func create(_ p: Player) {
        return allPlayers[p.id] = p
    }
    
    public func get(_ id: String) -> Player? {
        return allPlayers[id]
    }
    
    public func getAll() -> [Player] {
        return Array(allPlayers.values)
    }
    
    public func topPlayers(numPlayers: Int) -> [Player] {
        return Array(Array(allPlayers.values)
               .sorted(by: { Player.compareOverall($0, $1) > 0 })
               .prefix(numPlayers))
    }
    
    public func getRank(_ id: String ) -> Int? {
        guard let player = get(id) else {
            return nil
        }
        let wins = player.stats.numWins
        let numPlayersAhead = getAll()
            .filter{$0.stats.numWins > wins}
            .count
        return numPlayersAhead + 1
        }
    
    public func exists(_ id: String) -> Bool {
        return allPlayers[id] != nil
    }
    
}
