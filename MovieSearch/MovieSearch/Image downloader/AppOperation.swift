//
//  AppOperation.swift
//  ImageCaching
//
//  Created by Jageloo Yadav on 28/10/21.
//

import Foundation

class AppOperation: Operation {
    
    enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
        case downloaded
        case fail
        case cached
    }
    
    private var _state: State = .ready
    
    var state: State {
        get {
            return _state
        }
        set {
            DispatchQueue.global().async(flags: .barrier) {
                let oldValue = self._state
                self.willChangeValue(forKey: oldValue.rawValue)
                self.didChangeValue(forKey: newValue.rawValue)
                
                self._state = newValue
                
                self.willChangeValue(forKey: newValue.rawValue)
                self.didChangeValue(forKey: oldValue.rawValue)
            }
        }
    }
    
    var _isCancelled = false
    
    private var isCompleted = false
    
    override func start() {
        self.state = .executing
    }
    
    override func cancel() {
        _isCancelled = true
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isCancelled: Bool {
        return _isCancelled
    }
    
    override var isFinished: Bool {
        state == .finished || state == .fail || state == .downloaded || state == .cached
    }
}
