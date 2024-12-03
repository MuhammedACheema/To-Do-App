//
//  timer.swift
//  To-Do
//
//  Created by Muhammed Cheema on 11/3/24.
//

import Foundation
import Observation

enum TimerState: String {
    case idle
    case running
    case paused
}


enum TimerMode: String {
    case work
    case pause
}

@Observable
class PomodoroTimer{
    
    private var _mode: TimerMode = .work
    private var _state: TimerState = .idle
    
    private var _durationWork: TimeInterval
    private var _durationBreak: TimeInterval
    
    private var _secondsPassed: Int = 0
    private var _fractionPassed: Double = 0
    private var _dateStarted: Date = Date.now
    private var _secondsPassedBeforePause: Int = 0
    
    private var _timer: Timer?
    private var _audio: PomodoroAudio = PomodoroAudio()
    
    init(workInSeconds: TimeInterval, breakInSeconds: TimeInterval){
        _durationWork = workInSeconds
        _durationBreak = breakInSeconds
    }
    
    var secondsPassed: Int {
        return _secondsPassed
    }
    
    var secondsPassedString: String{
        return _formatSeconds(_secondsPassed)
    }
    
    var secondsLeft: Int{
        Int(_duration) - _secondsPassed
    }
    
    var secondsLeftString: String{
        return _formatSeconds(secondsLeft)
    }
    
    var fractionPassed: Double{
        return _fractionPassed
    }
    
    var fractionLeft: Double{
        1.0 - _fractionPassed
    }
    
    var state: TimerState {
        _state
    }
    
    var mode: TimerMode {
        _mode
    }
    
    private var _duration: TimeInterval {
        if _mode == .work{
            return _durationWork
        }else{
            return _durationBreak
        }
    }
    
    func start(){
        _dateStarted = Date.now
        _secondsPassed = 0
        _fractionPassed = 0
        _state = .running
        _createTimer()
    }
    
    func resume(){
        _dateStarted = Date.now
        _state = .running
        _createTimer()
    }
    
    func pause(){
        _secondsPassedBeforePause = _secondsPassed
        _state = .paused
        _killTimer()
    }
    
    func reset(){
        _secondsPassed = 0
        _fractionPassed = 0
        _secondsPassedBeforePause = 0
        _state = .idle
        _killTimer()
    }
    
    func skip(){
        if self._mode == .work{
            self._mode = .pause
        } else {
            self._mode = .work
        }
    }
    
    // private method that creates a timer
    
    private func _createTimer() {
        Notification.scheduleNotifications(seconds: TimeInterval(secondsLeft), title: "Timer Done", body: "Your Pomodoro timer is done")
        _timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){_ in
            self._onTick()
        }
    }
    
    private func _killTimer(){
        _timer?.invalidate()
        _timer = nil
        
    }
    
    private func _onTick(){
        //calcs the sec since start date
        let secondsSinceStartDate = Date.now.timeIntervalSince(self._dateStarted)
        
        // add the seconds before paused if any
        self._secondsPassed = Int(secondsSinceStartDate) + self._secondsPassedBeforePause
        // calc the fraction
        
        self._fractionPassed = TimeInterval(self._secondsPassed) / self._duration
        // done? play soun, reset, switch (work -> paused-> work), reset
        
        //play tick
        _audio.play(.tick)
        if self.secondsLeft == 0{
            self._fractionPassed = 0
            self.skip() // to switch mode
            self.reset() //will reset timer
            
            //play sounds
            _audio.play(.done)
        }
    }
    
    private func _formatSeconds(_ seconds: Int) -> String {
        if seconds <= 0{
            return "00:00"
        }
        
        let hh: Int = seconds / 3600
        let mm: Int = (seconds % 3600) / 60
        let ss: Int = seconds % 60
        
        if hh > 0{
            return String(format: "%02d:%02d:%02d", hh, mm, ss)
        }else{
            return String(format: "%02d:%02d", mm, ss)
        }
        
    }
}
