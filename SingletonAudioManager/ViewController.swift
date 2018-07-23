//
//  ViewController.swift
//  SingletonAudioManager
//
//  Created by 이광용 on 2018. 7. 23..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ViewController: UIViewController {
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var amplitudeLabel: UILabel!
    @IBOutlet weak var fftFrequencyLabel: UILabel!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    let bufferSize = Int(truncating: pow(2, AKSettings.bufferLength.rawValue) as NSNumber )
    
    lazy var fftPlot = AKNodeFFTPlot(AudioManager.shared.fftMic,
                                     frame: self.audioPlot.bounds,
                                     bufferSize: self.bufferSize)
    lazy var plot = AKNodeOutputPlot(AudioManager.shared.trackMic,
                                     frame: self.audioPlot.bounds,
                                     bufferSize: self.bufferSize)
    
    
    let audioManager = AudioManager.shared
    /* if you using notification center
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .get(.audioManager),
                                                  object: nil)
    }
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* if you using notification center
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(observeAudioManager(_:)),
                                               name: .get(.audioManager),
                                               object: nil)
         */
        // if you using delegate pattern
        AudioManager.shared.delegate = self
        setupPlot()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.fftPlot.frame = audioPlot.bounds
        self.plot.frame = self.audioPlot.bounds
    }
    
    func setupPlot() {
        fftPlot.shouldFill = true
        fftPlot.shouldMirror = false
        fftPlot.shouldCenterYAxis = false
        fftPlot.backgroundColor = .clear
        fftPlot.color = .blue
        fftPlot.gain = 100
        audioPlot.addSubview(fftPlot)
        
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.backgroundColor = .clear
        plot.color = .red
        plot.gain = 2
        audioPlot.addSubview(plot)
    }
    
    /* if you using notification center
    @objc func observeAudioManager(_ notification: Notification) {
        guard let userInfo =  notification.userInfo as? [String: Double],
            let frequency = userInfo["frequency"],
            let amplitude = userInfo["amplitude"],
            let fftFrequency = userInfo["fftFrequency"] else {return}
        updateLabels(frequency, amplitude, fftFrequency)
    }
     */
    
    func updateLabels(_ frequency: Double, _ amplitude: Double, _ fftFrequency: Double) {
        self.frequencyLabel.text = String(format: "Frequency : %0.2f", frequency)
        self.amplitudeLabel.text = String(format: "Amplitude : %0.2f", amplitude)
        self.fftFrequencyLabel.text = String(format: "FFT Frequency : %0.2f", fftFrequency)
    }
}

// if you using delegate pattern
extension ViewController: AudioManagerDelegate {
    func audioManger(_ manager: AudioManager, _ timer: Timer, _ frequency: Double, _ amplitude: Double, _ fftFrequency: Double) {
        updateLabels(frequency, amplitude, fftFrequency)
    }
}

