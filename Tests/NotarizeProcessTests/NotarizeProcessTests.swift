import XCTest
@testable import NotarizeProcess

final class NotarizeProcessTests: XCTestCase {

    /*func testDitto() {
        do {
            _ = try Ditto.run(arguments: [ "-c", "-k", "--rsrc", "--keepParent", "/Users/phimage/an.app", "\"/Users/phimage/an.app.zip\""])
        } catch {
            XCTFail("\(error)")
        }
    }*/

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

    func testAuditLog() {
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
        let expectation = self.expectation(description: "getauditlog")
        do {
            let history = try process.notarizationHistory()
            guard let item = history.items.first else {
                XCTFail("no history item to test audit log")
                return
            }
            guard let id = item.requestUUID  else {
                XCTFail("no requestUUID to test audit log")
                return
            }
            let info = try process.notarizationInfo(for: id)

            guard let publisher = info.auditLogPublisher() else {
                XCTFail("no publisher/logFileurl to test audit log")
                return
            }

            _ = publisher.sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("failed to get audit log: \(error)")
                }
            }) { auditLog in
                print("\(auditLog)")
                expectation.fulfill()
            }
        } catch {
            XCTFail("\(error)")
        }

        wait(for: [expectation], timeout: 10.0)
    }

    static var allTests = [
        ("testProcess", testProcess)
    ]
}
