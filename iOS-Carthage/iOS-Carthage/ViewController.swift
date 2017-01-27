import UIKit
import Nimble


class ViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    let recorder = AssertionRecorder()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sample usage of Nimble without XCTest.
        // This is verified via UI Tests
        NimbleAssertionHandler = recorder
        expect(1).to(equal(2))
        if let assertion = recorder.assertions.first {
            textView.text = assertion.message.stringValue
        }
    }
}

