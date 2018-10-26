import Foundation


import LoggerAPI
import Health
import KituraContracts

func initializeRoundRoutes(app: App) {
    app.router.get("/round/listAllGames", handler: app.getRounds)
    app.router.post("/round/createRound") { request, response, next in
        response.send(app.createRound())
    }
    app.router.post("round/createRoundById", handler: app.createRoundById)
    app.router.get("round/available") { request, response, next in
        let rounds = Array(app.allRounds.values)
        for round in rounds {
            if round.isOpen() {
                response.send(round.id)
                return next()
            }
        }
        response.send(app.createRound())
    }
}
extension App {
    func getRounds(completion: ([GameRound]?, RequestError?) -> Void ) {
        let rounds = Array(allRounds.values)
        completion(rounds, nil)
    }
    func createRoundById(gameId: GameId, completion: (GameRound?, RequestError?) -> Void ) {
        let gameRound = GameRound(id: gameId.gameId)
        self.allRounds[gameRound.id] = gameRound
        Log.verbose("Created round id= \(gameRound.id)")
        if self.allRounds.count > 5 {
            Log.warning("Over 5 gameRounds")
        }
    }
    func createRound() -> String {
        let gameRound = GameRound()
        self.allRounds[gameRound.id] = gameRound
        Log.verbose("Created round id= \(gameRound.id)")
        if self.allRounds.count > 5 {
            Log.warning("Over 5 gameRounds")
        }
        return gameRound.id
    }
}

struct GameId: Codable {
    let gameId: String
}
