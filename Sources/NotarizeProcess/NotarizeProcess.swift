//
//  NotarizeProcess.swift
//
//
//  Created by phimage on 20/10/2019.
//
import Foundation
import NotarizationInfo

/// Object to notarize app or get notarization informations.
public struct NotarizeProcess {

    private var username: String
    private var password: String
    private var ascProvider: String?

    /// - Returns:`true` if `altool`is available.
    public static var isAvailable: Bool {
        let out = try? XcRun.run(arguments: ["altool", "--help"])
        return out?.count ?? 0 > 0
    }

    /// Initialize process with account information.
    ///
    /// - Parameters:
    ///   - username: The required username
    ///   - password: The required password
    ///   - ascProvider: Required when a user account is associated with multiple providers.
    public init(username: String, password: String, ascProvider: String? = nil) {
        self.username = username
        self.password = password
        self.ascProvider = ascProvider
    }

    // MARK: - notarize

    /// Uploads the given app package, dmg or zip file for notarization.
    ///
    /// - Parameters:
    ///   - app: specifies the path to the file to process
    ///   - bundleId  Used to uniquely identify a package
    ///
    /// - Throws: `NotarizeProcessError`
    /// - Returns: A `NotarizationUpload`.
    public func notarize(app: URL, bundleId: String, type: NotarizePlatform = .osx) throws -> NotarizationUpload {
        var args = ["--notarize-app", "-t", type.rawValue]
        args.append(contentsOf: ["-f", "\"\(app.path)\"", "--primary-bundle-id", bundleId])
        if let ascProvider = ascProvider {
            args.append(contentsOf: ["--asc-provider", "\"\(ascProvider)\""])
        }
        let out = try run(arguments: args)
        let response = try decode(out)
        do {
            return try response.getNotarizationUpload()
        } catch let error as DecodingError {
            throw NotarizeProcessError.decodingError(error)
        } catch {
            throw error // unknown
        }
    }

    // MARK: - history

    /// Returns a list of all uploads submitted for notarization.
    ///
    /// - Parameters:
    ///   - page: specifies the path to the file to process
    ///
    /// - Throws: `NotarizeProcessError`
    /// - Returns: A `NotarizationHistory`which contains a list of `NotarizationInfo`.
    public func notarizationHistory(for page: Int = 0, ascProvider: String? = nil) throws -> NotarizationHistory {
        var args = ["--notarization-history"]
        if page > 0 {
            args.append("\(page)")
        }
        if let ascProvider = ascProvider {
            args.append(contentsOf: ["--asc-provider", "\"\(ascProvider)\""])
        }
        let out = try run(arguments: args)
        let response = try decode(out)
        do {
            return try response.getNotarizationHistory()
        } catch let error as DecodingError {
            throw NotarizeProcessError.decodingError(error)
        } catch {
            throw error // unknown
        }
    }

    // MARK: - info

    /// Returns the status and log file URL of a package previously uploaded for notarization with the specified <uuid>
    /// - Parameters:
    ///   - uuid: unique uuid for your upload
    ///
    /// - Throws: `NotarizeProcessError`
    /// - Returns: A `NotarizationInfo`.
    public func notarizationInfo(for uuid: String) throws -> NotarizationInfo {
        let out = try run(arguments: ["--notarization-info", uuid])
        let response = try decode(out)
        do {
            return try response.getNotarizationInfo()
        } catch let error as DecodingError {
            throw NotarizeProcessError.decodingError(error)
        } catch {
            throw error // unknown
        }
    }

    /// Returns the status and log file URL of a package previously uploaded.
    /// - Parameters:
    ///   - info: info from history.
    ///
    /// - Throws: `NotarizeProcessError`
    /// - Returns: An updated `NotarizationInfo`.
    public func notarizationInfo(for info: NotarizationInfo) throws -> NotarizationInfo {
        guard let requestUUID = info.requestUUID else {
            return info
        }
        return try notarizationInfo(for: requestUUID)
    }

    /// Returns the status and log file URL of a package previously uploaded.
    /// - Parameters:
    ///   - upload: result of your upload
    ///
    /// - Throws: `NotarizeProcessError`
    /// - Returns: A `NotarizationInfo` for uploaded app.
    public func notarizationInfo(for upload: NotarizationUpload) throws -> NotarizationInfo {
        return try notarizationInfo(for: upload.requestUUID)
    }

    // MARK: - wait info

    public func waitForNotarizationInfo(for uuid: String, sleepTime: TimeInterval = 5, sleepTimeFactor: Int = 2, timeout: TimeInterval = 30 * 60, waitMethod: WaitMethod = .runLoop) throws -> NotarizationInfo {
        var total: TimeInterval = 0
        var sleep: TimeInterval = sleepTime

        var info = try notarizationInfo(for: uuid)
        while info.status == .inProgress {
            // No results were available so wait and try again
            if total < timeout {
                waitMethod.wait(for: sleep)
                total += sleep
                sleep = min(sleep * TimeInterval(sleepTimeFactor), TimeInterval(60) /* Do not wait more than 1 minute for any */)
            } else {
                throw NotarizeProcessError.timeOut(timeout)
            }
            info = try notarizationInfo(for: uuid)
        }
        return info
    }

    public func waitForNotarizationInfo(for info: NotarizationInfo, sleepTime: TimeInterval = 5, sleepTimeFactor: Int = 2, timeout: TimeInterval = 30 * 60, waitMethod: WaitMethod = .runLoop) throws -> NotarizationInfo {
        guard let requestUUID = info.requestUUID else {
            return info
        }
        return try waitForNotarizationInfo(for: requestUUID, sleepTime: sleepTime, sleepTimeFactor: sleepTimeFactor, timeout: timeout, waitMethod: waitMethod)
    }

    public func waitForNotarizationInfo(for upload: NotarizationUpload, sleepTime: TimeInterval = 5, sleepTimeFactor: Int = 2, timeout: TimeInterval = 30 * 60, waitMethod: WaitMethod = .runLoop) throws -> NotarizationInfo {
        return try waitForNotarizationInfo(for: upload.requestUUID, sleepTime: sleepTime, sleepTimeFactor: sleepTimeFactor, timeout: timeout, waitMethod: waitMethod)
    }

    // MARK: - staple

    /// Retrieves a ticket and attaches it to the supported file format at path.
    ///
    /// - Parameters:
    ///   - app: url of the file.
    ///
    /// - Throws: `NotarizeProcessError.processError`
    public func staple(app: URL) throws {
        do {
            _ = try XcRun.run(arguments: ["stapler", "staple", "--verbose", "\"\(app.path)\""])
        } catch {
            throw NotarizeProcessError.processError(error)
        }
    }

    /// Validates an existing stapled ticket.
    ///
    /// - Parameters:
    ///   - app: url of the file.
    ///
    /// - Throws: `NotarizeProcessError.processError`
    public func validate(app: URL) throws {
        do {
            _ = try XcRun.run(arguments: ["stapler", "validate", "--verbose", "\"\(app.path)\""])
        } catch {
            throw NotarizeProcessError.processError(error)
        }
    }

    // MARK: - privates
    private func decode(_ data: Data) throws -> NotarizationResponse {
        do {
            return try NotarizationResponse(from: data)
        } catch let error as NotarizationError {
            throw NotarizeProcessError.notaryError(error)
        } catch let error as DecodingError {
            throw NotarizeProcessError.decodingError(error)
        } catch {
            throw error // unknown
        }
    }

    private func run(arguments: [String]) throws -> Data {
        do {
            var args = ["altool"]
            args.append(contentsOf: arguments)
            args.append(contentsOf: ["-u", self.username, "-p", self.password, "--output-format", "xml"])
            return try XcRun.run(arguments: args)
        } catch {
            throw NotarizeProcessError.processError(error)
        }
    }

}
