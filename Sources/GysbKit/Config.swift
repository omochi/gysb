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
    public var packageDependencies: [PackageDependency] = []
    public var targetDependencies: [TargetDependency] = []
}

public extension Config {
    public static func fromJSON(path: URL) throws -> Config {
        let data = try Data.init(contentsOf: path)
        return try JSONDecoder().decode(Config.self, from: data)
    }
}
