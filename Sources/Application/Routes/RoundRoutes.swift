import Foundation


import LoggerAPI
import Health
import KituraContracts

func initializeRoundRoutes(app: App) {
    
    app.router.get("/round") { (respondWith: (Status?, RequestError?) -> Void) -> Void in
        if health.status.state == .UP {
            respondWith(health.status, nil)
        } else {
            respondWith(nil, RequestError(.serviceUnavailable, body: health.status))
        }
    }
    
}
