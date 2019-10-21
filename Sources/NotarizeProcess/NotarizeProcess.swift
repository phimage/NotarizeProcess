import NotarizationInfo
import Foundation

public enum NotarizeProcessError: Error {
    case notaryError(NotarizationError)
    case processError(Error)
    case decodingError(DecodingError)
}

public struct NotarizeProcess {

    private var username: String
    private var password: String

    public static var isAvailable: Bool {
        let out = try? XcRun.run(arguments: ["altool", "--help"])
        return out?.count ?? 0 > 0
    }

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public func notarizationHistory(page: Int = 0) throws -> NotarizationHistory {
        var args = ["--notarization-history"]
        if page > 0 {
            args.append("\(page)")
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
