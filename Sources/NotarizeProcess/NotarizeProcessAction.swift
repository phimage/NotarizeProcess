//
//  NotarizeProcessAction.swift
//  
//
//  Created by phimage on 24/10/2019.
//

import Foundation
import NotarizationInfo

public struct NotarizeProcessAction: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let notarize = NotarizeProcessAction(rawValue: 1 << 0)
    public static let wait = NotarizeProcessAction(rawValue: 1 << 1)
    public static let staple = NotarizeProcessAction(rawValue: 1 << 2)

    public static let all: NotarizeProcessAction = [ .notarize, .wait, .staple]
}

// MARK: - run

public extension NotarizeProcess {

    func run(action: NotarizeProcessAction = .all, on app: URL, with bundleId: String = "", type: NotarizePlatform = .osx) throws -> NotarizationInfo? {
        if action.contains(.notarize) {
            let upload = try notarize(app: app, bundleId: bundleId, type: type)
            if action.contains(.wait) {
                let info = try waitForNotarizationInfo(for: upload)
                if action.contains(.staple) {
                    if info.status == .success {
                        try staple(app: app)
                    }
                }
                return info
            } else {
                return try firstNotarizationInfo(for: upload.requestUUID)
            }
        }
        return nil
    }
}
