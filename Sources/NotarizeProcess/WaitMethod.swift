//
//  WaitMethod.swift
//  
//
//  Created by phimage on 23/10/2019.
//

import Foundation

/// Wait method.
public enum WaitMethod {
    /// Do a `run` on current loop.
    case runLoop
    /// Call a thread sleep.
    case thread
    /// Implement your own wait method.
    case custom((TimeInterval) -> Void)

    public func wait(for timeInterval: TimeInterval) {
        switch self {
        case .runLoop:
            RunLoop.current.run(until: Date(timeIntervalSinceNow: timeInterval))
        case .thread:
            Thread.sleep(forTimeInterval: timeInterval)
        case .custom(let waitCallback):
            waitCallback(timeInterval)
        }
    }
}
