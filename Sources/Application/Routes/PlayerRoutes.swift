import LoggerAPI
import Health
import KituraContracts

func initializePlayerRoutes(app: App) {
    app.router.get("/player", handler: app.playerHandler)
    
}

extension App {
    func playerHandler(completion: ([Player]?, RequestError?) -> Void ) {
        
    }
}
//@Path("/player")
//@ApplicationScoped
//public class PlayerService {
//
//    @Inject
//    PlayerDB db;
//
//    @Resource(lookup = "jwtKeyStore")
//    protected String keyStore;
//
//    @Inject
//    @ConfigProperty(name = "jwtKeyStorePassword", defaultValue = "secret2")
//    String keyStorePW;
//    @Inject
//    @ConfigProperty(name = "jwtKeyStoreAlias", defaultValue = "rebike")
//    String keyStoreAlias;
//
//    @Inject
//    private JsonWebToken callerPrincipal;
//
//    @GET
//    @Produces(MediaType.APPLICATION_JSON)
//    public Collection<Player> getPlayers() {
//    return db.getAll();
//    }
//
//    @POST
//    @Path("/create")
//    public String createPlayer(@QueryParam("name") String name, @QueryParam("id") String id) {
//    // Validate player name
//    if (name == null)
//    return null;
//    name = name.replaceAll("[^a-zA-Z0-9 -]", "").trim();
//    if (name.length() == 0)
//    return null;
//    if (name.length() > 20)
//    name = name.substring(0, 20);
//
//    Player p = new Player(name, id);
//    if (db.create(p))
//    System.out.println("Created a new player with id=" + p.id);
//    else
//    System.out.println("A player already existed with id=" + p.id);
//    return p.id;
//    }
//
//    @GET
//    @Path("/{playerId}")
//    @Produces(MediaType.APPLICATION_JSON)
//    public Player getPlayerById(@PathParam("playerId") String id) {
//    if (id == null)
//    return null;
//    Player p = db.get(id);
//    if (p == null)
//    System.out.println("Unable to find any player with id=" + id);
//    return p;
//    }
//
//    @GET
//    @Path("/getJWTInfo")
//    @Produces("application/json")
//    public HashMap<String, String> getJWTInfo() {
//
//    HashMap<String, String> map = new HashMap<String, String>();
//
//    String id = callerPrincipal.getClaim("id");
//    if (db.exists(id)) {
//    map.put("exists", "true");
//    map.put("username", db.get(id).name);
//
//    } else {
//    map.put("exists", "false");
//    }
//    map.put("id", id);
//    return map;
//    }
//}

