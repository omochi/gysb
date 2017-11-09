//
//  PackageDependency.swift
//  GysbSwiftConfig
//
//  Created by omochimetaru on 2017/11/10.
//

import Foundation
import GysbBase

public struct PackageDependency : Decodable {
    public enum Requirement : Decodable {
        case exact(String)
        case revision(String)
        
        public init(from decoder: Decoder) throws {
            let kc = try decoder.container(keyedBy: CodingKeys.self)
            let type = try kc.decode(String.self, forKey: .type)
            switch type {
            case "exact":
                let id = try kc.decode(String.self, forKey: .identifier)
                self = .exact(id)
            case "revision":
                let id = try kc.decode(String.self, forKey: .identifier)
                self = .revision(id)
            default:
                throw Error(message: "invalid type: \(type)")
            }
        }
        
        public enum CodingKeys : String, CodingKey {
            case type
            case identifier
        }
    }
    
    public var url: String
    public var requirement: Requirement
}
