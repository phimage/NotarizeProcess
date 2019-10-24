//
//  Processable.swift
//  
//
//  Created by phimage on 21/10/2019.
//

import Foundation

protocol Processable {
    static var launchPath: String { get }
}

extension Processable {
    static func run(arguments: [String]) throws -> Data {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = self.launchPath
        process.arguments = arguments
        process.standardOutput = pipe

        try process.run()

        process.waitUntilExit()
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }
}

struct XcRun: Processable {
    static var launchPath = "/usr/bin/xcrun"
}

struct Ditto: Processable {
    static var launchPath = "/usr/bin/ditto"
}
