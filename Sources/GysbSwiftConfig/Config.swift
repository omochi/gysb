
public struct Config : Decodable {
    public init() {}
    public var packageDependencies: [PackageDependency] = []
    public var targetDependencies: [TargetDependency] = []
}
