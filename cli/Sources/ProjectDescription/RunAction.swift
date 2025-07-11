/// An action that runs the built products.
///
/// It's initialized with the .runAction static method.
public struct RunAction: Equatable, Codable, Sendable {
    /// Indicates the build configuration the product should run with.
    public var configuration: ConfigurationName

    /// Whether a debugger should be attached to the run process or not.
    public var attachDebugger: Bool

    /// The path of custom lldbinit file.
    public var customLLDBInitFile: Path?

    /// A list of actions that are executed before starting the run process.
    public var preActions: [ExecutionAction]

    /// A list of actions that are executed after the run process.
    public var postActions: [ExecutionAction]

    /// The name of the executable or target to run.
    public var executable: TargetReference?

    /// Command line arguments passed on launch and environment variables.
    public var arguments: Arguments?

    /// List of options to set to the action.
    public var options: RunActionOptions

    /// List of diagnostics options to set to the action.
    public var diagnosticsOptions: SchemeDiagnosticsOptions

    /// List of metal options to set to the action
    public var metalOptions: MetalOptions

    /// A target that will be used to expand the variables defined inside Environment Variables definition (e.g. $SOURCE_ROOT)
    public var expandVariableFromTarget: TargetReference?

    /// The launch style of the action
    public var launchStyle: LaunchStyle

    /// The URL string used to invoke the app clip, if available.
    public var appClipInvocationURLString: String?

    init(
        configuration: ConfigurationName,
        attachDebugger: Bool = true,
        customLLDBInitFile: Path? = nil,
        preActions: [ExecutionAction] = [],
        postActions: [ExecutionAction] = [],
        executable: TargetReference? = nil,
        arguments: Arguments? = nil,
        options: RunActionOptions = .options(),
        diagnosticsOptions: SchemeDiagnosticsOptions = .options(),
        metalOptions: MetalOptions = .options(),
        expandVariableFromTarget: TargetReference? = nil,
        launchStyle: LaunchStyle = .automatically,
        appClipInvocationURLString: String? = nil
    ) {
        self.configuration = configuration
        self.attachDebugger = attachDebugger
        self.customLLDBInitFile = customLLDBInitFile
        self.preActions = preActions
        self.postActions = postActions
        self.executable = executable
        self.arguments = arguments
        self.options = options
        self.diagnosticsOptions = diagnosticsOptions
        self.metalOptions = metalOptions
        self.expandVariableFromTarget = expandVariableFromTarget
        self.launchStyle = launchStyle
        self.appClipInvocationURLString = appClipInvocationURLString
    }

    /// Returns a run action.
    /// - Parameters:
    ///   - configuration: Indicates the build configuration the product should run with.
    ///   - attachDebugger: Whether a debugger should be attached to the run process or not.
    ///   - preActions: A list of actions that are executed before starting the run process.
    ///   - postActions: A list of actions that are executed after the run process.
    ///   - executable: The name of the executable or target to run.
    ///   - arguments: Command line arguments passed on launch and environment variables.
    ///   - options: List of options to set to the action.
    ///   - diagnosticsOptions: List of diagnostics options to set to the action.
    ///   - metalOptions: List of metal options to set to the action.
    ///   - expandVariableFromTarget: A target that will be used to expand the variables defined inside Environment Variables
    /// definition (e.g. $SOURCE_ROOT). When nil, it does not expand any variables.
    ///   - appClipInvocationURLString: The URL string used to invoke the app clip, if available.
    ///   - launchStyle: The launch style of the action
    /// - Returns: Run action.
    public static func runAction(
        configuration: ConfigurationName = .debug,
        attachDebugger: Bool = true,
        customLLDBInitFile: Path? = nil,
        preActions: [ExecutionAction] = [],
        postActions: [ExecutionAction] = [],
        executable: TargetReference? = nil,
        arguments: Arguments? = nil,
        options: RunActionOptions = .options(),
        diagnosticsOptions: SchemeDiagnosticsOptions = .options(),
        metalOptions: MetalOptions = .options(),
        expandVariableFromTarget: TargetReference? = nil,
        launchStyle: LaunchStyle = .automatically,
        appClipInvocationURLString: String? = nil
    ) -> RunAction {
        RunAction(
            configuration: configuration,
            attachDebugger: attachDebugger,
            customLLDBInitFile: customLLDBInitFile,
            preActions: preActions,
            postActions: postActions,
            executable: executable,
            arguments: arguments,
            options: options,
            diagnosticsOptions: diagnosticsOptions,
            metalOptions: metalOptions,
            expandVariableFromTarget: expandVariableFromTarget,
            launchStyle: launchStyle,
            appClipInvocationURLString: appClipInvocationURLString
        )
    }
}
