//
//  ViewController.swift
//  iOS-Cocoapods
//
//  Created by Jeff Hui on 9/21/15.
//  Copyright © 2015 Jeff Hui. All rights reserved.
//

import UIKit
import Nimble


class ViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    let recorder = AssertionRecorder()

    override func viewDidLoad() {
        super.viewDidLoad()

        NimbleAssertionHandler = recorder

        expect(1).to(equal(2))

        if let assertion = recorder.assertions.first {
            textView.text = assertion.message.stringValue
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

