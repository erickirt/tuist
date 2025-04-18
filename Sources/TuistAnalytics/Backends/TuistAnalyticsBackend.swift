import TuistCore

/// An analytics backend  an entity (e.g. an HTTP server)
/// that can process analytics events generated by the Tuist CLI.
public protocol TuistAnalyticsBackend: AnyObject {
    /// Sends a command event to the backend.
    /// - Parameter commandEvent: Command event to be delivered.
    func send(commandEvent: CommandEvent) async throws
}
