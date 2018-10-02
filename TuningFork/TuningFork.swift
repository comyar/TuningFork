//
//  TuningFork.swift
//  TuningFork
//
//  Copyright (c) 2015 Comyar Zaheri. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//


// MARK:- Imports

import AudioKit
//import Chronos


// MARK:- Constants

private let flats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
private let sharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
private let frequencies: [Double] = [
     16.35, 17.32, 18.35, 19.45, 20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87, // 0
     32.70, 34.65, 36.71, 38.89, 41.20, 43.65, 46.25, 49.00, 51.91, 55.00, 58.27, 61.74, // 1
     65.41, 69.30, 73.42, 77.78, 82.41, 87.31, 92.50, 98.00, 103.8, 110.0, 116.5, 123.5, // 2
     130.8, 138.6, 146.8, 155.6, 164.8, 174.6, 185.0, 196.0, 207.7, 220.0, 233.1, 246.9, // 3
     261.6, 277.2, 293.7, 311.1, 329.6, 349.2, 370.0, 392.0, 415.3, 440.0, 466.2, 493.9, // 4
     523.3, 554.4, 587.3, 622.3, 659.3, 698.5, 740.0, 784.0, 830.6, 880.0, 932.3, 987.8, // 5
     1047, 1109, 1175, 1245, 1319, 1397, 1480, 1568, 1661, 1760, 1865, 1976,             // 6
     2093, 2217, 2349, 2489, 2637, 2794, 2960, 3136, 3322, 3520, 3729, 3951,             // 7
     4186, 4435, 4699, 4978, 5274, 5588, 5920, 6272, 6645, 7040, 7459, 7902              // 8
]


// MARK:- TunerDelegate Protocol

/**
 Types adopting the TunerDelegate protocol act as callbacks for Tuners and are
 the mechanism by which you may receive and respond to new information decoded
 by a Tuner.
 */
@objc public protocol TunerDelegate {
     
     /**
      Called by a Tuner on each update.
      
      - parameter tuner: Tuner that performed the update.
      - parameter output: Contains information decoded by the Tuner.
      */
     func tunerDidUpdate(_ tuner: Tuner, output: TunerOutput)
}

// MARK:- TunerOutput

/**
 Contains information decoded by a Tuner, such as frequency, octave, pitch, etc.
 */
@objc public class TunerOutput: NSObject {
     
     /**
      The octave of the interpreted pitch.
      */
     public fileprivate(set) var octave: Int = 0
     
     /**
      The interpreted pitch of the microphone audio.
      */
     public fileprivate(set) var pitch: String = ""
     
     /**
      The difference between the frequency of the interpreted pitch and the actual
      frequency of the microphone audio.
      
      For example if the microphone audio has a frequency of 432Hz, the pitch will
      be interpreted as A4 (440Hz), thus making the distance -8Hz.
      */
     public fileprivate(set) var distance: Double = 0.0
     
     /**
      The amplitude of the microphone audio.
      */
     public fileprivate(set) var amplitude: Double = 0.0
     
     /**
      The frequency of the microphone audio.
      */
     public fileprivate(set) var frequency: Double = 0.0
     
     fileprivate override init() {}
}


// MARK:- Tuner

/**
 A Tuner uses the devices microphone and interprets the frequency, pitch, etc.
 */
@objc public class Tuner: NSObject {
     
     fileprivate let updateInterval: TimeInterval = 0.03
     fileprivate let smoothingBufferCount = 30
     
     /**
      Object adopting the TunerDelegate protocol that should receive callbacks
      from this tuner.
      */
     public var delegate: TunerDelegate?
     
     fileprivate let threshold: Double
     fileprivate let smoothing: Double
     fileprivate let microphone: AKMicrophone
     fileprivate let tracker: AKFrequencyTracker
     fileprivate let silence: AKBooster
     fileprivate var timer: Timer?
     fileprivate var smoothingBuffer: [Double] = []
     
     /**
      Initializes a new Tuner.
      
      - parameter threshold: The minimum amplitude to recognize, 0 < threshold < 1
      - parameter smoothing: Exponential smoothing factor, 0 < smoothing < 1
      
      */
     public init(threshold: Float = 0.0, smoothing: Float = 0.25) {
          self.threshold = Double(min(abs(threshold), 1.0))
          self.smoothing = Double(min(abs(smoothing), 1.0))
          microphone = AKMicrophone()
          tracker = AKFrequencyTracker(microphone)
          silence = AKBooster(tracker, gain: 0)
     }
     
     /**
      Starts the tuner.
      */
     public func start() throws {
          microphone.start()
          tracker.start()
          AudioKit.output = silence
          try AudioKit.start()
          
          if timer == nil {
               timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
          }
     }
     
     @objc private func tick() {
          if let d = self.delegate {
               if self.tracker.amplitude > self.threshold {
                    let amplitude = self.tracker.amplitude
                    let frequency = self.smooth(self.tracker.frequency)
                    let output = Tuner.newOutput(frequency, amplitude)
                    DispatchQueue.main.async {
                         d.tunerDidUpdate(self, output: output)
                    }
               }
          }
     }
     
     /**
      Stops the tuner.
      */
     public func stop() throws {
          microphone.stop()
          tracker.stop()
          try AudioKit.stop()
          timer?.invalidate()
     }
     
     /**
      Exponential smoothing:
      https://en.wikipedia.org/wiki/Exponential_smoothing
      */
     fileprivate func smooth(_ value: Double) -> Double {
          var frequency = value
          if smoothingBuffer.count > 0 {
               let last = smoothingBuffer.last!
               frequency = (smoothing * value) + (1.0 - smoothing) * last
               if smoothingBuffer.count > smoothingBufferCount {
                    smoothingBuffer.removeFirst()
               }
          }
          smoothingBuffer.append(frequency)
          return frequency
     }
     
     static func newOutput(_ frequency: Double, _ amplitude: Double) -> TunerOutput {
          let output = TunerOutput()
          
          var norm = frequency
          while norm > frequencies[frequencies.count - 1] {
               norm = norm / 2.0
          }
          while norm < frequencies[0] {
               norm = norm * 2.0
          }
          
          var i = -1
          var min = Double.infinity
          for n in 0...frequencies.count-1 {
               let diff = frequencies[n] - norm
               if abs(diff) < abs(min) {
                    min = diff
                    i = n
               }
          }
          
          output.octave = i / 12
          output.frequency = frequency
          output.amplitude = amplitude
          output.distance = frequency - frequencies[i]
          output.pitch = String(format: "%@", sharps[i % sharps.count], flats[i % flats.count])
          
          return output
     }
}
