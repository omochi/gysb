//
//  Process.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

struct ExecError : Swift.Error, CustomStringConvertible {
    var path: String
    var arguments: [String]
    var statusCode: Int32
    var stderr: String
    
    var description: String {
        var ls = [
            "process execution failure",
            "path=[\(path)]"
            ]
        ls += arguments.enumerated().map { (i, arg) in
            "arg[\(i)]=[\(arg)]" }
        ls += [
            "statusCode=[\(statusCode)]",
            "stderr=",
            ""]
        
        return ls.joined(separator: "\n") + stderr + "\n"
    }
}

@discardableResult
func execCapture(path: URL,
                 arguments: [String]) throws -> String
{
    let stdoutPipe = Pipe()
    var stdoutData = Data()
    stdoutPipe.fileHandleForReading.readabilityHandler = { file in
        stdoutData.append(file.availableData)
    }
    
    let stderrPipe = Pipe()
    var stderrData = Data()
    stderrPipe.fileHandleForReading.readabilityHandler = { file in
        stderrData.append(file.availableData)
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
    guard let stdoutStr = String.init(data: stdoutData, encoding: .utf8) else {
        throw Error(message: "stdout decode failed")
    }
    guard let stderrStr = String.init(data: stderrData, encoding: .utf8) else {
        throw Error(message: "stderr decode failed")
    }
    
    if process.terminationStatus != EXIT_SUCCESS {
        throw ExecError(path: path.path,
                        arguments: arguments,
                        statusCode: process.terminationStatus,
                        stderr: stderrStr)
    }
    
    return stdoutStr
}

func execWhich(name: String) throws -> String {
    var path = try execCapture(path: URL.init(fileURLWithPath: "/usr/bin/which"),
                               arguments: [name])
    path = path.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    return path
}

