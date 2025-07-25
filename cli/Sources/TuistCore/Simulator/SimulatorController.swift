import Foundation
import Mockable
import Path
import struct TSCUtility.Version
import TuistSupport
import XcodeGraph

@Mockable
public protocol SimulatorControlling {
    /// Finds first available device defined by given parameters
    /// - Parameters:
    ///     - platform: Given platform
    ///     - version: Specific version, ignored if nil
    ///     - minVersion: Minimum version of the OS
    ///     - deviceName: Specific device name (eg. iPhone X)
    func findAvailableDevice(
        platform: Platform,
        version: Version?,
        minVersion: Version?,
        deviceName: String?
    ) async throws -> SimulatorDeviceAndRuntime

    /// Ask the user to select one of the available devices defined by given parameters
    /// if there is more than one, otherwise return the only one available
    /// - Parameters:
    ///    - platform: Given platform
    ///    - version: Specific version, ignored if nil
    ///    - minVersion: Minimum version of the OS
    ///    - deviceName: Specific device name (eg. iPhone X)
    func askForAvailableDevice(
        platform: Platform,
        version: Version?,
        minVersion: Version?,
        deviceName: String?
    ) async throws -> SimulatorDeviceAndRuntime

    func findAvailableDevices(
        platform: Platform,
        version: Version?,
        minVersion: Version?,
        deviceName: String?
    ) async throws -> [SimulatorDeviceAndRuntime]

    func findAvailableDevice(
        deviceName: String?,
        version: Version?
    ) async throws -> SimulatorDeviceAndRuntime?

    func findAvailableDevice(
        udid: String
    ) async throws -> SimulatorDeviceAndRuntime?

    /// Installs an app on a given simulator.
    /// - Parameters:
    ///   - path: The path to the app to install in the simulator.
    ///   - device: The simulator device to install the app on.
    func installApp(at path: AbsolutePath, device: SimulatorDevice) throws

    /// Opens the simulator application & launches app on the given simulator.
    /// - Parameters:
    ///   - bundleId: The bundle id of the app to launch.
    ///   - device: The simulator device to install the app on.
    ///   - arguments: Any additional arguments to pass the app on launch.
    func launchApp(bundleId: String, device: SimulatorDevice, arguments: [String]) async throws

    /// Finds the simulator destination for the target platform
    /// - Parameters:
    ///     - targetPlatform: Given platform
    ///     - version: Specific version, ignored if nil
    ///     - deviceName: Specific device name (eg. iPhone X)
    func destination(
        for targetPlatform: Platform,
        version: Version?,
        deviceName: String?
    ) async throws -> String

    /// Returns the simulator destination for the macOS platform
    func macOSDestination(catalyst: Bool) async throws -> String

    /// Returns the list of simulator devices that are available in the system.
    func devices() async throws -> [SimulatorDevice]

    /// Returns the list of simulator runtimes that are available in the system.
    func devicesAndRuntimes() async throws -> [SimulatorDeviceAndRuntime]

    /// Boots a simulator, if necessary
    /// - Returns: A simulator with the updated `state`
    func booted(device: SimulatorDevice) throws -> SimulatorDevice

    /// Boots a simulator, if necessary
    /// - Parameters:
    ///     - forced: If `true`, booting of the simulator is forced
    func booted(device: SimulatorDevice, forced: Bool) throws -> SimulatorDevice
}

public enum SimulatorControllerError: Equatable, FatalError {
    case simctlError(String)
    case deviceNotFound(Platform, Version?, String?, [SimulatorDeviceAndRuntime])
    case simulatorNotFound(udid: String)

    public var type: ErrorType {
        switch self {
        case .simctlError,
             .deviceNotFound,
             .simulatorNotFound:
            return .abort
        }
    }

    public var description: String {
        switch self {
        case let .simctlError(output):
            return output
        case let .deviceNotFound(platform, version, deviceName, devices):
            return "Could not find a suitable device for \(platform.caseValue)\(version.map { " \($0)" } ?? "")\(deviceName.map { ", device name \($0)" } ?? ""). Did find \(devices.map { "\($0.device.name) (\($0.runtime.description))" }.joined(separator: ", "))"
        case let .simulatorNotFound(udid):
            return "Could not find simulator with UDID: \(udid)"
        }
    }
}

public final class SimulatorController: SimulatorControlling {
    private let jsonDecoder = JSONDecoder()
    private let userInputReader: UserInputReading

    private let system: Systeming

    public init(
        userInputReader: UserInputReading = UserInputReader(),
        system: Systeming = System.shared
    ) {
        self.userInputReader = userInputReader
        self.system = system
    }

    /// Returns the list of simulator devices that are available in the system.
    public func devices() async throws -> [SimulatorDevice] {
        let output = try await system.runAndCollectOutput(["/usr/bin/xcrun", "simctl", "list", "devices", "--json"])
        let data = output.standardOutput.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: Any],
              let devicesJSON = dictionary["devices"] as? [String: [[String: Any]]]
        else {
            return []
        }

        let devices = try devicesJSON.flatMap { runtimeIdentifier, devicesJSON -> [SimulatorDevice] in
            try devicesJSON.map { deviceJSON -> SimulatorDevice in
                var deviceJSON = deviceJSON
                deviceJSON["runtimeIdentifier"] = runtimeIdentifier
                let deviceJSONData = try JSONSerialization.data(withJSONObject: deviceJSON, options: [])
                return try self.jsonDecoder.decode(SimulatorDevice.self, from: deviceJSONData)
            }
        }
        return devices
    }

    /// Returns the list of simulator runtimes that are available in the system.
    func runtimes() async throws -> [SimulatorRuntime] {
        let output = try await system.runAndCollectOutput(["/usr/bin/xcrun", "simctl", "list", "runtimes", "--json"])
        let data = output.standardOutput.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: Any],
              let runtimesJSON = dictionary["runtimes"] as? [Any]
        else {
            return []
        }

        let runtimesData = try JSONSerialization.data(withJSONObject: runtimesJSON, options: [])
        let runtimes = try jsonDecoder.decode([SimulatorRuntime].self, from: runtimesData)
        return runtimes
    }

    /// - Parameters:
    ///     - platform: Optionally filter by platform
    ///     - deviceName: Optionally filter by device name
    /// - Returns: the list of simulator devices and runtimes.
    public func devicesAndRuntimes() async throws -> [SimulatorDeviceAndRuntime] {
        async let runtimesTask = runtimes()
        async let devicesTask = devices()
        let (runtimes, devices) = try await (runtimesTask, devicesTask)
        return devices.compactMap { device -> SimulatorDeviceAndRuntime? in
            guard let runtime = runtimes.first(where: { $0.identifier == device.runtimeIdentifier }) else { return nil }
            return SimulatorDeviceAndRuntime(device: device, runtime: runtime)
        }
    }

    public func findAvailableDevices(
        platform: Platform,
        version: Version?,
        minVersion: Version?,
        deviceName: String?
    ) async throws -> [SimulatorDeviceAndRuntime] {
        let devicesAndRuntimes = try await devicesAndRuntimes()
        let availableDevices = devicesAndRuntimes
            .sorted(by: { $0.runtime.version >= $1.runtime.version })
            .filter { simulatorDeviceAndRuntime in
                guard simulatorDeviceAndRuntime.device.isAvailable else { return false }
                let nameComponents = simulatorDeviceAndRuntime.runtime.name.components(separatedBy: " ")
                guard nameComponents.first == platform.caseValue else { return false }
                let deviceVersion = nameComponents.last?.version()
                if let version {
                    guard deviceVersion == version else { return false }
                } else if let minVersion, let deviceVersion {
                    guard deviceVersion >= minVersion else { return false }
                }
                if let deviceName {
                    guard simulatorDeviceAndRuntime.device.name == deviceName else { return false }
                }

                return true
            }

        let maxRuntimeVersion = availableDevices.map(\.runtime.version).max()

        return availableDevices.filter { simulatorDeviceAndRuntime in
            if version == nil, let maxRuntimeVersion {
                return simulatorDeviceAndRuntime.runtime.version == maxRuntimeVersion
            } else {
                return true
            }
        }
    }

    public func findAvailableDevice(
        platform: Platform,
        version: Version?,
        minVersion: Version?,
        deviceName: String?
    ) async throws -> SimulatorDeviceAndRuntime {
        let availableDevices = try await findAvailableDevices(
            platform: platform,
            version: version,
            minVersion: minVersion,
            deviceName: deviceName
        )
        guard let device = availableDevices.first(where: { !$0.device.isShutdown }) ?? availableDevices.first
        else {
            throw SimulatorControllerError.deviceNotFound(platform, version, deviceName, try await devicesAndRuntimes())
        }
        return device
    }

    public func findAvailableDevice(
        deviceName: String?,
        version: Version?
    ) async throws -> SimulatorDeviceAndRuntime? {
        let devicesAndRuntimes = try await devicesAndRuntimes()
        return devicesAndRuntimes
            .sorted(by: { $0.runtime.version < $1.runtime.version })
            .filter(\.device.isAvailable)
            .first(where: {
                if version != nil, Version(
                    $0.runtime.version.major,
                    $0.runtime.version.minor ?? 0,
                    $0.runtime.version.patch ?? 0
                ) != version {
                    return false
                }
                return $0.device.name == deviceName
            })
    }

    public func findAvailableDevice(
        udid: String
    ) async throws -> SimulatorDeviceAndRuntime? {
        let devicesAndRuntimes = try await devicesAndRuntimes()
        guard let device = devicesAndRuntimes
            .first(where: { $0.device.udid == udid })
        else {
            throw SimulatorControllerError.simulatorNotFound(udid: udid)
        }
        return device
    }

    public func askForAvailableDevice(
        platform: Platform,
        version: Version?,
        minVersion: Version?,
        deviceName: String?
    ) async throws -> SimulatorDeviceAndRuntime {
        let availableDevices = try await findAvailableDevices(
            platform: platform,
            version: version,
            minVersion: minVersion,
            deviceName: deviceName
        )
        if availableDevices.isEmpty {
            throw SimulatorControllerError.deviceNotFound(
                platform,
                version,
                deviceName,
                try await devicesAndRuntimes()
            )
        }
        let availableBootedDevices = availableDevices.filter { !$0.device.isShutdown }
        if availableBootedDevices.count == 1, let onlyOption = availableBootedDevices.first {
            return onlyOption
        }
        return try userInputReader.readValue(
            asking: "Select the simulator device where you want to run the app:",
            values: availableDevices,
            valueDescription: { "\($0.device.name) (\($0.device.udid)" }
        )
    }

    public func installApp(at path: AbsolutePath, device: SimulatorDevice) throws {
        Logger.current.debug("Installing app at \(path) on simulator device with id \(device.udid)")
        let device = try device.booted(using: system)
        try system.run(["/usr/bin/xcrun", "simctl", "install", device.udid, path.pathString])
    }

    public func launchApp(bundleId: String, device: SimulatorDevice, arguments: [String]) async throws {
        Logger.current
            .debug("Launching app with bundle id \(bundleId) on simulator device with id \(device.udid)")
        let device = try device.booted(using: system)
        let simulator = try await XcodeController.current.selected().path.appending(
            components: "Contents",
            "Developer",
            "Applications",
            "Simulator.app"
        )
        try system.run(["/usr/bin/open", "-a", simulator.pathString])
        try system.run(["/usr/bin/xcrun", "simctl", "launch", device.udid, bundleId] + arguments)
    }

    public func booted(device: SimulatorDevice) throws -> SimulatorDevice {
        try device.booted(using: system)
    }

    public func booted(device: SimulatorDevice, forced: Bool) throws -> SimulatorDevice {
        try device.booted(using: system, forced: forced)
    }

    /// https://www.mokacoding.com/blog/xcodebuild-destination-options/
    /// https://www.mokacoding.com/blog/how-to-always-run-latest-simulator-cli/
    public func destination(
        for targetPlatform: Platform,
        version: Version?,
        deviceName: String?
    ) async throws -> String {
        var platform: Platform!
        switch targetPlatform {
        case .iOS: platform = .iOS
        case .watchOS: platform = .watchOS
        case .tvOS: platform = .tvOS
        case .visionOS: platform = .visionOS
        case .macOS:
            return try await macOSDestination()
        }

        let deviceAndRuntime = try await findAvailableDevice(
            platform: platform,
            version: version,
            minVersion: nil,
            deviceName: deviceName
        )
        return "id=\(deviceAndRuntime.device.udid)"
    }

    public func macOSDestination(catalyst: Bool = false) async throws -> String {
        let arch: String
        switch try await Environment.current.architecture() {
        case .arm64:
            arch = "arm64"
        case .x8664:
            arch = "x86_64"
        }
        let destination = "platform=macOS,arch=\(arch)"
        if catalyst {
            return destination + ",variant=Mac Catalyst"
        } else {
            return destination
        }
    }
}

extension SimulatorDevice {
    /// Attempts to boot the simulator.
    /// - returns: The `SimulatorDevice` with updated `isShutdown` field.
    fileprivate func booted(using system: Systeming, forced: Bool = false) throws -> Self {
        guard isShutdown || forced else { return self }
        do {
            try system.run(["/usr/bin/xcrun", "simctl", "boot", udid])
        } catch {
            if forced, let error = error as? FatalError,
               error.description.contains("Unable to boot device in current state: Booted")
            {
                // noop
            } else {
                throw error
            }
        }
        return SimulatorDevice(
            dataPath: dataPath,
            logPath: logPath,
            udid: udid,
            isAvailable: isAvailable,
            deviceTypeIdentifier: deviceTypeIdentifier,
            state: "Booted",
            name: name,
            availabilityError: availabilityError,
            runtimeIdentifier: runtimeIdentifier
        )
    }
}
