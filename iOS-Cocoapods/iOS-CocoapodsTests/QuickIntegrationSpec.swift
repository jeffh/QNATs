import Quick
import Nimble
@testable import iOS_Cocoapods

class QuickIntegrationSpec: QuickSpec {
    override func spec() {
        describe("Running this test") {
            it("should work") {
                expect(1).to(equal(1))
                XCTAssertEqual(1, 1)
            }
        }
    }
}
