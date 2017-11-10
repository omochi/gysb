//
//  Process.swift
//  gysb
//
//  Created by omochimetaru on 2017/11/09.
//

import Foundation

public struct ExecError : Swift.Error, CustomStringConvertible {
    public init(path: URL,
                arguments: [String],
                statusCode: Int32,
                output: String?)
    {
        self.path = path
        self.arguments = arguments
        self.statusCode = statusCode
        self.output = output
    }
    
    public var path: URL
    public var arguments: [String]
    public var statusCode: Int32
    public var output: String?
    
    public var description: String {
        var ls = [
            "process execution failure",
            "path=[\(path.path)]"
            ]
        ls += arguments.enumerated().map { (i, arg) in
            "arg[\(i)]=[\(arg)]" }
        ls += [
            "statusCode=[\(statusCode)]" ]
        
        if let output = self.output {
            ls += [
                "output=",
                output]
        }
        
        ls += [""]

        return ls.joined(separator: "\n")
    }
}

public func execRaw(path: URL,
                    arguments: [String],
                    stdout: @escaping (Data) -> Void,
                    stderr: @escaping (Data) -> Void)
    throws -> Int32
{
    let stdoutPipe = Pipe()
    stdoutPipe.fileHandleForReading.readabilityHandler = { file in
        stdout(file.availableData)
    }
    
    let stderrPipe = Pipe()
    stderrPipe.fileHandleForReading.readabilityHandler = { file in
        stderr(file.availableData)
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
    
    return process.terminationStatus
}

@discardableResult
public func execCapture(path: URL,
                        arguments: [String]) throws -> String
{
    var outputData = Data()
    
    let st = try execRaw(path: path,
                         arguments: arguments,
                         stdout: { outputData.append($0) },
                         stderr: { outputData.append($0) })
    
    let outputStr = decodeString(data: outputData, coding: .utf8)
    
    if st != EXIT_SUCCESS {
        throw ExecError(path: path,
                        arguments: arguments,
                        statusCode: st,
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

public func execPrintOrCapture(path: URL,
                               arguments: [String],
                               print: ((String) -> Void)?)
    throws
{
    let status: Int32
    var output: String?
    
    if let print = print {
        status = try execRaw(path: path, arguments: arguments,
                             stdout: { print(decodeString(data: $0, coding: .utf8)) },
                             stderr: { print(decodeString(data: $0, coding: .utf8)) })

    } else {
        output = ""
        status = try execRaw(path: path, arguments: arguments,
                             stdout: { output!.append(decodeString(data: $0, coding: .utf8)) },
                             stderr: { output!.append(decodeString(data: $0, coding: .utf8)) })

    }
    
    if status != EXIT_SUCCESS {
        throw ExecError(path: path, arguments: arguments,
                        statusCode: status, output: output)
    }
}

