//
//  ViewController.swift
//  VoiceSearch
//
//  Created by Jageloo Yadav on 29/11/21.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        SpeechRecogniser().authorise { success in
            print("success == \(success)")
        }
    }
}

