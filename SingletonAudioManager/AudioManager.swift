//
//  AudioManager.swift
//  SingletonAudioManager
//
//  Created by 이광용 on 2018. 7. 23..
//  Copyright © 2018년 이광용. All rights reserved.
//

import Foundation
import AudioKit

//https://github.com/AudioKit/AudioKit/issues/748
//https://github.com/audiokit/AudioKit/blob/master/AudioKit/Common/User%20Interface/AKNodeFFTPlot.swift#L33

// if you use delegate pattern
protocol AudioManagerDelegate {
    func audioManger(_ manager: AudioManager, _ timer: Timer, _ frequency: Double, _ amplitude: Double, _ fftFrequency: Double)
}

class AudioManager: NSObject {
    static let shared = AudioManager()
    
    var mic: AKMicrophone = AKMicrophone()
    var fftMic: AKBooster? // for use in 'AKNodeFFTPlot'
    var trackMic: AKBooster? // for use in 'AKNodeOutputPlot'
    private var fftBooster: AKBooster?
    private var booster: AKBooster?
    private var tracker: AKFrequencyTracker?
    private var silence: AKBooster?
    private var tap: AKFFTTap?
    private var timer: Timer?
    // if you use delegate pattern
    var delegate: AudioManagerDelegate?
    
    override private init() {
        super.init()
        AKSettings.audioInputEnabled = true
        
        AKSettings.sampleRate = 44100
        AKSettings.bufferLength = .veryLong //1024
        
        if let inputs = AudioKit.inputDevices {
            do {
                try AudioKit.setInputDevice(inputs[0])
                try mic.setDevice(inputs[0])
            }
            catch {
                NSLog(error.localizedDescription)
            }
        }
        self.fftMic = AKBooster(self.mic)
        self.trackMic = AKBooster(self.mic)
        
        self.fftBooster = AKBooster(self.mic)
        guard let fftBooster = self.fftBooster else {return}
        self.booster = AKBooster(self.mic)
        guard let booster = self.booster else {return}
        self.tracker = AKFrequencyTracker.init(booster)
        guard let tracker = self.tracker else {return}
        self.silence = AKBooster(tracker, gain: 0.0)
        guard let silence = self.silence  else {return}
        AudioKit.output = silence
        self.start()
        self.tap = AKFFTTap(fftBooster)
        startTimer()
    }
    
    private func start() {
        do {
            try AudioKit.start()
        }
        catch {
            NSLog(error.localizedDescription)
        }
    }
    
    private func stop() {
        do {
            try AudioKit.stop()
        }
        catch {
            NSLog(error.localizedDescription)
        }
    }
    
    private func startTimer() {
        if self.timer == nil {
            if #available(iOS 10.0, *) {
                self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
                    self.updateTimer(timer)
                }
            } else {
                self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                                                  target: self,
                                                  selector: #selector(updateTimer),
                                                  userInfo: nil,
                                                  repeats: true)
            }
        }
    }
    
    private func fftToFrequency(_ tap: AKFFTTap?, bufferSize: Int) -> Double {
        guard let maxValue = tap?.fftData.max() else {return 0.0}
        guard let index = tap?.fftData.index(of: maxValue) else {return 0.0}
        return index * AKSettings.sampleRate / bufferSize
    }
    
    @objc private func updateTimer(_ sender: Timer) {
        guard let tracker = self.tracker else {return}
        let bufferSize = Int(truncating: pow(2, AKSettings.bufferLength.rawValue) as NSNumber )
        let fftFrequency = fftToFrequency(tap, bufferSize: bufferSize)
        
        /* if you using notification center
        NotificationCenter.default.post(name: .get(.audioManager),
                                        object: nil,
                                        userInfo: ["frequency" : tracker.frequency,
                                                   "amplitude" : tracker.amplitude,
                                                   "fftFrequency" : fftFrequency])
         */
        
        // if you use delegate pattern
        self.delegate?.audioManger(self,
                                   sender,
                                   tracker.frequency,
                                   tracker.amplitude,
                                   fftFrequency)
    }
}

