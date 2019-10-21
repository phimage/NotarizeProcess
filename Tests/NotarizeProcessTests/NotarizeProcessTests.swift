import XCTest
@testable import NotarizeProcess

final class NotarizeProcessTests: XCTestCase {
    func testProcess() {
        let environment = ProcessInfo.processInfo.environment
        guard let username = environment["NOTARIZE_USERNAME"] else {
            XCTFail("No username to test. Define NOTARIZE_USERNAME")
            return
        }
        guard let password = environment["NOTARIZE_PASSWORD"] else {
            XCTFail("No password to test. Define NOTARIZE_PASSWORD. Could be keyhain notation")
            return
        }
        let process = NotarizeProcess(username: username, password: password)
        
        do {
            let history = try process.notarizationHistory()
            for item in history.items {
                if let id = item.requestUUID {
                    let info = try process.notarizationInfo(for: id)
                    print("\(info)")
                }
            }
        } catch {
            XCTFail("\(error)")
        }
    }
    
    static var allTests = [
        ("testProcess", testProcess)
    ]
}
