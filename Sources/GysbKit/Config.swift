import Foundation

public struct Config : Decodable {
    public struct PackageDependency : Decodable {
        public enum Requirement : Decodable {
            case exact(String)
            case revision(String)
            
            public enum CodingKeys : String, CodingKey {
                case type
                case identifier
            }
        }
        
        public var url: String
        public var requirement: Requirement
    }

    public struct TargetDependency : Decodable {
        public var name: String
    }
    
    public init() {}
    public var packageDependencies: [PackageDependency] {
        get {
            return _packageDependencies ?? []
        }
        set {
            _packageDependencies = newValue
        }
    }
    public var targetDependencies: [TargetDependency] {
        get {
            return _targetDependencies ?? []
        }
        set {
            _targetDependencies = newValue
        }
    }
    
    private var _packageDependencies: [PackageDependency]?
    private var _targetDependencies: [TargetDependency]?
    
    public enum CodingKeys : String, CodingKey {
        case _packageDependencies = "packageDependencies"
        case _targetDependencies = "targetDependencies"
    }
}

public extension Config {
    public static func fromJSON(path: URL) throws -> Config {
        let data = try Data.init(contentsOf: path)
        return try JSONDecoder().decode(Config.self, from: data)
    }
}
