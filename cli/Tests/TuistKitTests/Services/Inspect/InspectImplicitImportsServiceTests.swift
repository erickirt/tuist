import Foundation
import Mockable
import Path
import TuistCore
import TuistLoader
import TuistSupport
import TuistTesting
import XcodeGraph
import XCTest

@testable import TuistKit

final class LintImplicitImportsServiceTests: TuistUnitTestCase {
    private var configLoader: MockConfigLoading!
    private var generatorFactory: MockGeneratorFactorying!
    private var targetScanner: MockTargetImportsScanning!
    private var subject: InspectImplicitImportsService!
    private var generator: MockGenerating!

    override func setUp() {
        super.setUp()
        configLoader = MockConfigLoading()
        generatorFactory = MockGeneratorFactorying()
        targetScanner = MockTargetImportsScanning()
        generator = MockGenerating()
        subject = InspectImplicitImportsService(
            generatorFactory: generatorFactory,
            configLoader: configLoader,
            graphImportsLinter: GraphImportsLinter(targetScanner: targetScanner)
        )
    }

    override func tearDown() {
        configLoader = nil
        generatorFactory = nil
        targetScanner = nil
        generator = nil
        subject = nil
        super.tearDown()
    }

    func test_run_throwsAnError_when_thereAreIssues() async throws {
        // Given
        let path = try AbsolutePath(validating: "/project")
        let config = Tuist.test()
        let app = Target.test(name: "App", product: .app)
        let framework = Target.test(name: "Framework", product: .framework)
        let project = Project.test(path: path, targets: [app, framework])
        let graph = Graph.test(path: path, projects: [path: project])

        given(configLoader).loadConfig(path: .value(path)).willReturn(config)
        given(generatorFactory).defaultGenerator(config: .value(config), includedTargets: .any).willReturn(generator)
        given(generator).load(path: .value(path), options: .any).willReturn(graph)
        given(targetScanner).imports(for: .value(app)).willReturn(Set(["Framework"]))
        given(targetScanner).imports(for: .value(framework)).willReturn(Set([]))

        let expectedError = LintingError()

        // When
        await XCTAssertThrowsSpecific(try await subject.run(path: path.pathString), expectedError)
    }

    func test_run_when_external_package_target_is_implicitly_imported() async throws {
        // Given
        let path = try AbsolutePath(validating: "/project")
        let config = Tuist.test()
        let app = Target.test(name: "App", product: .app)
        let project = Project.test(path: path, targets: [app])
        let testTarget = Target.test(name: "PackageTarget", product: .app)
        let externalProject = Project.test(path: path, targets: [testTarget], type: .external(hash: "hash"))
        let graph = Graph.test(
            path: path,
            projects: [path: project, "/a": externalProject]
        )

        given(configLoader).loadConfig(path: .value(path)).willReturn(config)
        given(generatorFactory).defaultGenerator(config: .value(config), includedTargets: .any).willReturn(generator)
        given(generator).load(path: .value(path), options: .any).willReturn(graph)
        given(targetScanner).imports(for: .value(app)).willReturn(Set(["PackageTarget"]))

        let expectedError = LintingError()

        // When / Then
        await XCTAssertThrowsSpecific(try await subject.run(path: path.pathString), expectedError)
    }

    func test_run_when_external_package_target_is_explicitly_imported() async throws {
        // Given
        let path = try AbsolutePath(validating: "/project")
        let config = Tuist.test()
        let app = Target.test(name: "App", product: .app)
        let project = Project.test(path: path, targets: [app])
        let testTarget = Target.test(name: "PackageTarget", product: .app)
        let externalProject = Project.test(path: path, targets: [testTarget], type: .external(hash: "hash"))
        let graph = Graph.test(
            path: path,
            projects: [path: project, "/a": externalProject],
            dependencies: [GraphDependency.target(name: "App", path: path): Set([
                GraphDependency.target(name: "PackageTarget", path: "/a"),
            ])]
        )

        given(configLoader).loadConfig(path: .value(path)).willReturn(config)
        given(generatorFactory).defaultGenerator(config: .value(config), includedTargets: .any).willReturn(generator)
        given(generator).load(path: .value(path), options: .any).willReturn(graph)
        given(targetScanner).imports(for: .value(app)).willReturn(Set(["PackageTarget"]))
        given(targetScanner).imports(for: .value(testTarget)).willReturn(Set())

        // When / Then
        try await subject.run(path: path.pathString)
    }

    func test_run_when_external_package_target_is_recursively_imported() async throws {
        // Given
        let path = try AbsolutePath(validating: "/project")
        let config = Tuist.test()
        let app = Target.test(name: "App", product: .app)
        let project = Project.test(path: path, targets: [app])
        let testTarget = Target.test(name: "PackageTarget", product: .app)
        let externalTargetDependency = Target.test(name: "PackageTargetDependency", product: .app)
        let externalProject = Project.test(
            path: path,
            targets: [testTarget, externalTargetDependency],
            type: .external(hash: "hash")
        )
        let graph = Graph.test(
            path: path,
            projects: [path: project, "/a": externalProject],
            dependencies: [
                GraphDependency.target(name: "App", path: path): Set([
                    GraphDependency.target(name: "PackageTarget", path: "/a"),
                ]),
                GraphDependency
                    .target(
                        name: "PackageTarget",
                        path: "/a"
                    ): Set([GraphDependency.target(name: "PackageTargetDependency", path: "/a")]),
            ]
        )

        given(configLoader).loadConfig(path: .value(path)).willReturn(config)
        given(generatorFactory).defaultGenerator(config: .value(config), includedTargets: .any).willReturn(generator)
        given(generator).load(path: .value(path), options: .any).willReturn(graph)
        given(targetScanner).imports(for: .value(app)).willReturn(Set(["PackageTargetDependency"]))

        // When / Then
        try await subject.run(path: path.pathString)
    }

    func test_run_doesntThrowAnyErrors_when_thereAreNoIssues() async throws {
        // Given
        let path = try AbsolutePath(validating: "/project")
        let config = Tuist.test()
        let app = Target.test(name: "App", product: .app)
        let framework = Target.test(name: "Framework", product: .framework)
        let project = Project.test(path: path, targets: [app, framework])
        let graph = Graph.test(
            path: path,

            projects: [path: project],
            dependencies: [.target(name: app.name, path: path): Set([.target(
                name: framework.name,
                path: path
            )])]
        )

        given(configLoader).loadConfig(path: .value(path)).willReturn(config)
        given(generatorFactory).defaultGenerator(config: .value(config), includedTargets: .any).willReturn(generator)
        given(generator).load(path: .value(path), options: .any).willReturn(graph)
        given(targetScanner).imports(for: .value(app)).willReturn(Set(["Framework"]))
        given(targetScanner).imports(for: .value(framework)).willReturn(Set([]))

        // When
        try await subject.run(path: path.pathString)
    }
}
