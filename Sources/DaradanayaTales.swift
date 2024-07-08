import ArgumentParser
import Hummingbird
import Logging
import PostgresNIO
import ServiceLifecycle

@main
struct DaradanayaTales: AsyncParsableCommand, AppArguments {
    
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    @Flag(name: .shortAndLong)
    var inMemoryTesting: Bool = false

    func run() async throws {
        // create application
        let app = try await buildApplication(self)
        // run application
        do {
            try await app.runService()
        } catch {
            app.logger.error("Error running application: \(error)")
            print(String(reflecting: error))
            throw error
        }
    }
}

/// Arguments extracted from commandline
protocol AppArguments {
    var hostname: String { get }
    var port: Int { get }
    var inMemoryTesting: Bool { get }
}

/// Build a HBApplication
func buildApplication(_ args: some AppArguments) async throws -> some ApplicationProtocol {
    var logger = Logger(label: "DaradanayaTales")
    logger.logLevel = .debug
    // create router
    let router = Router()
    // add logging middleware
    router.add(middleware: LogRequestsMiddleware(.info))
    // add hello route
    router.get("/") { request, context in
        "Hello\n"
    }
    // add Danaya API
    var postgresRepository: PostgresRepository?
    if !args.inMemoryTesting {
        let client = PostgresClient(
            configuration: .init(host: "XXX.XXX.X.X", port: 0000, username: "yyyyyy", password: "xxxxxxxxxxxx", database: "zzzzzzzzzz", tls: .disable),
            backgroundLogger: logger
        )
        let repository = PostgresRepository(client: client, logger: logger)
        postgresRepository = repository
        DanayaController(repository: repository).addRoutes(to: router.group("danaya"))
    } else {
        DanayaController(repository: MemoryRepository()).addRoutes(to: router.group("danaya"))
    }
    // create application
    var app = Application(
        router: router,
        configuration: .init(address: .hostname(args.hostname, port: args.port)),
        logger: logger
    )
    // create telegram bot actor
    let botActor = TGBotActor()
    try await configure(app, logger: logger, actor: botActor)
    // add controller routes
    TelegramController().addRoutes(to: router.group("tgbot"), actor: botActor)
    // if we setup a postgres service then add as a service and run createTable before
    // server starts
    if let postgresRepository {
        app.addServices(postgresRepository.client)
        app.beforeServerStarts {
            try await postgresRepository.createTable()
        }
    }
    return app
}
