import Cocoa
import Nimble


class ViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    let recorder = AssertionRecorder()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sample usage of Nimble without XCTest.
        // This is verified via UI Tests
        NimbleAssertionHandler = recorder
        expect(1).to(equal(2))
        if let assertion = recorder.assertions.first {
            let str = NSAttributedString(string: assertion.message.stringValue)
            textView.textStorage?.setAttributedString(str)
        }
    }
}
