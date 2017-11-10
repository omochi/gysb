//
//  ManifestoGenerator.swift
//  GysbSwiftConfig
//
//  Created by omochimetaru on 2017/11/10.
//

import Foundation
import GysbBase

public class ManifestoGenerator {
    public init(config: Config, targetNames: [String]) {
        self.config = config
        self.targetNames = targetNames
    }
    
    public func generate() -> String {
        
        let packageName = "GysbRender"
        
        write("// swift-tools-version:4.0")
        write("")
        write("import PackageDescription")
        write("")
        write("let package = Package(")
        write("    name: \"\(packageName)\",")
        write("    dependencies: [")
        
        for (i, pd) in config.packageDependencies.enumerated() {
            let last = i + 1 == config.packageDependencies.count
            let comma = last ? "" : ","

            write("        .package(url: \"\(escapeToSwiftLiteral(text: pd.url))\",")
            switch pd.requirement {
            case .exact(let id):
                write("                 .exact(\"\(id)\")")
            case .revision(let id):
                write("                 .revision(\"\(id)\")")
            }
            write("                 )\(comma)")
        }
        
        write("    ],")
        write("    targets: [")
        
        for (i, targetName) in self.targetNames.enumerated() {
            let last = i + 1 == self.targetNames.count
            let comma = last ? "" : ","
            
            write("        .target(name: \"\(targetName)\",")
            write("                dependencies: [")
            
            for (i, td) in config.targetDependencies.enumerated() {
                let last = i + 1 == config.targetDependencies.count
                let comma = last ? "" : ","
                
                write("                    \"\(td.name)\"\(comma)")
            }
            
            write("                ]")
            write("                )\(comma)")
        }
        
        write("    ]")
        write(")\n")
        
        return output
    }
    
    private func write(_ s: String) {
        output.append(s + "\n")
    }
    
    private var output: String = ""
    private let config: Config
    private let targetNames: [String]
}
