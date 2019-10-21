//
//  File.swift
//  
//
//  Created by phimage on 21/10/2019.
//

import Foundation

struct XcRun {

    static func run(arguments: [String]) throws -> Data {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = "/usr/bin/xcrun"
        process.arguments = arguments
        process.standardOutput = pipe

        try process.run()

        process.waitUntilExit()
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }

}
