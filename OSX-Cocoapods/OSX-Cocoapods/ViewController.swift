//
//  ViewController.swift
//  OSX-Cocoapods
//
//  Created by Jeff Hui on 9/22/15.
//  Copyright © 2015 Jeff Hui. All rights reserved.
//

import Cocoa
import Nimble


class ViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    let recorder = AssertionRecorder()

    override func viewDidLoad() {
        super.viewDidLoad()

        NimbleAssertionHandler = recorder

        expect(1).to(equal(2))

        if let assertion = recorder.assertions.first {
            textView.insertText(assertion.message.stringValue)
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

