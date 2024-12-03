//
//  PomodoroAudio.swift
//  To-Do
//
//  Created by Muhammed Cheema on 10/26/24.
//
import Foundation
import AVFoundation

//Groups the type of sound thats why its enum
enum PomodoroAudioSounds{
    case done
    case tick
    
    var resource: String{
        switch self{
        case .done:
            return "bell.wav"
        case .tick:
            return "tick.wav"
        }
    }
}

class PomodoroAudio{
    private var _audioPlayer: AVAudioPlayer?
    func play(_ sound: PomodoroAudioSounds){
        let path = Bundle.main.path(forResource: sound.resource, ofType: nil)!
        let url = URL(filePath: path)
        
        do{
            _audioPlayer = try AVAudioPlayer(contentsOf: url)
            _audioPlayer?.play()
        }catch{
            print(error.localizedDescription)
        }
        
    }
}
