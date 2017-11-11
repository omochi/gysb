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

public class Thread : Foundation.Thread {
    public init(_ f: @escaping () -> Void) {
        self.f = f
    }
    
    public override func main() {
        f?()
        
        cond.lock()
        exited = true
        cond.signal()
        cond.unlock()
        
        f = nil
    }
    
    public func join() {
        cond.lock()
        while !exited {
            cond.wait()
        }
        cond.unlock()
    }
    
    private var f: (() -> Void)? = nil
    private var exited: Bool = false
    private var cond: NSCondition = .init()
}

public func execRaw(path: URL,
                    arguments: [String],
                    stdout: @escaping (Data) -> Void,
                    stderr: @escaping (Data) -> Void)
    throws -> Int32
{
    let stdoutPipe = Pipe()
    let stdoutThread = Thread {
        while true {
            let chunk = stdoutPipe.fileHandleForReading.availableData
            if chunk.count == 0 {
                break
            }
            stdout(chunk)
        }
    }
    stdoutThread.start()

    let stderrPipe = Pipe()
    let stderrThread = Thread {
        while true {
            let chunk = stderrPipe.fileHandleForReading.availableData
            if chunk.count == 0 {
                break
            }
            stderr(chunk)
        }
    }
    stderrThread.start()
    
    let process = Process()
    process.launchPath = path.path
    process.arguments = arguments
    process.standardOutput = stdoutPipe
    process.standardError = stderrPipe
    process.launch()
    
    process.waitUntilExit()
    
    stdoutThread.join()
    stderrThread.join()
    
    return process.terminationStatus
}

@discardableResult
public func execCapture(path: URL,
                        arguments: [String]) throws -> String
{
    var outputData = Data()
    let lock = NSLock()
    
    let st = try execRaw(path: path,
                         arguments: arguments,
                         stdout: { chunk in
                            lock.scope {
                                outputData.append(chunk) } },
                         stderr: { chunk in
                            lock.scope {
                                outputData.append(chunk) } })
    
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
    let lock = NSLock()

    if let print = print {
        status = try execRaw(path: path, arguments: arguments,
                             stdout: { chunk in
                                lock.scope {
                                    print(decodeString(data: chunk, coding: .utf8))
                                } },
                             stderr: { chunk in
                                lock.scope {
                                    print(decodeString(data: chunk, coding: .utf8))
                                } })

    } else {
        output = ""
        status = try execRaw(path: path, arguments: arguments,
                             stdout: { chunk in
                                lock.scope {
                                    output!.append(decodeString(data: chunk, coding: .utf8))
                                } },
                             stderr: { chunk in
                                lock.scope {
                                    output!.append(decodeString(data: chunk, coding: .utf8))
                                } })

    }
    
    if status != EXIT_SUCCESS {
        throw ExecError(path: path, arguments: arguments,
                        statusCode: status, output: output)
    }
}

