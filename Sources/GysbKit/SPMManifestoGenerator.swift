//
//  ManifestoGenerator.swift
//  GysbSwiftConfig
//
//  Created by omochimetaru on 2017/11/10.
//

import Foundation
import GysbBase

public class SPMManifestoGenerator {
    public init(config: Config,
                targetNames: [String],
                includeFilesTargetName: String,
                hasIncludeFiles: Bool)
    {
        self.config = config
        self.targetNames = targetNames
        self.includeFilesTargetName = includeFilesTargetName
        self.hasIncludeFiles = hasIncludeFiles
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
        
        let commonDepDefs: [String] = config.targetDependencies
            .map { td in
                "                \"\(td.name)\""
            }
        var templateDepDefs: [String] = commonDepDefs
        if hasIncludeFiles {
            templateDepDefs.append("                \"\(includeFilesTargetName)\"")
        }
        
        var targetDefs: [String] = self.targetNames.map { targetName -> String in
            var ls: [String] = []
            ls.append("        .target(")
            ls.append("            name: \"\(targetName)\",")
            ls.append("            dependencies: [")
            
            if templateDepDefs.count > 0 {
                ls.append(templateDepDefs.joined(separator: ",\n"))
            }
            
            ls.append("            ]")
            ls.append("        )")
            return ls.joined(separator: "\n")
        }
        if hasIncludeFiles {
            var ls = [String]()
            ls.append("        .target(")
            ls.append("            name: \"\(includeFilesTargetName)\",")
            ls.append("            dependencies: [")

            if commonDepDefs.count > 0 {
                ls.append(commonDepDefs.joined(separator: ",\n"))
            }
            
            ls.append("            ]")
            ls.append("        )")
            targetDefs.append(ls.joined(separator: "\n"))
        }
        
        let targetDefsStr = targetDefs.joined(separator: ",\n")
        if !targetDefsStr.isEmpty {
            write(targetDefsStr)
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
    private let includeFilesTargetName: String
    private let hasIncludeFiles: Bool
}
