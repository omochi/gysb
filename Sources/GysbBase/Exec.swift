//
//  Process.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

public struct ExecError : Swift.Error, CustomStringConvertible {
    public var path: String
    public var arguments: [String]
    public var statusCode: Int32
    public var output: String
    
    public var description: String {
        var ls = [
            "process execution failure",
            "path=[\(path)]"
            ]
        ls += arguments.enumerated().map { (i, arg) in
            "arg[\(i)]=[\(arg)]" }
        ls += [
            "statusCode=[\(statusCode)]",
            "output=",
            output,
            ""]

        return ls.joined(separator: "\n")
    }
}

@discardableResult
public func execCapture(path: URL,
                        arguments: [String]) throws -> String
{
    let stdoutPipe = Pipe()
    var outputData = Data()
    stdoutPipe.fileHandleForReading.readabilityHandler = { file in
        outputData.append(file.availableData)
    }
    
    let stderrPipe = Pipe()
    stderrPipe.fileHandleForReading.readabilityHandler = { file in
        outputData.append(file.availableData)
    }
    
    let process = Process()
    process.launchPath = path.path
    process.arguments = arguments
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe
    process.launch()
    process.waitUntilExit()
    
    stdoutPipe.fileHandleForReading.readabilityHandler = nil
    stderrPipe.fileHandleForReading.readabilityHandler = nil
    
    // TODO: robust decoding to prevent failure always
    guard let outputStr = String.init(data: outputData, encoding: .utf8) else {
        throw Error(message: "output data decode failed")
    }
    
    if process.terminationStatus != EXIT_SUCCESS {
        throw ExecError(path: path.path,
                        arguments: arguments,
                        statusCode: process.terminationStatus,
                        output: outputStr)
    }
    
    return outputStr
}

public func execWhich(name: String) throws -> URL {
    var path = try execCapture(path: URL.init(fileURLWithPath: "/usr/bin/which"),
                               arguments: [name])
    path = path.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    return URL.init(fileURLWithPath: path)
}

