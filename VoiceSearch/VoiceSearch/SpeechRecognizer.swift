//
//  SpeechRecognizer.swift
//  VoiceSearch
//
//  Created by Jageloo Yadav on 29/11/21.
//

import Foundation
import Speech

class SpeechRecogniser {
    
    func authorise(completion: ((Bool) -> Void)?) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
                case .authorized:
                    completion?(false)
                case .denied:
                    completion?(false)
                    print("Speech recognition authorization denied")
                case .restricted:
                    completion?(false)
                    print("Not available on this device")
                case .notDetermined:
                    completion?(false)
                    print("Not determined")
                default:
                    completion?(false)
                    break
            }
        }
    }
}
