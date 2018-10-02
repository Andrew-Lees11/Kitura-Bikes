import Foundation

public class PlayerStats: Codable {
    
    public var totalGames: Int = 0
    
    public var numWins: Int = 0
    
    public var rating = 1000
    
    public var winLossRatio: Double {
        return totalGames == 0 ? 0 : Double(numWins) / Double(totalGames)
    }
    
}
