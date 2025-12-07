//
//  BreathDetector.swift
//  MahaPeriyavaPranayama
//

import Foundation
import AVFoundation
import Combine

enum BreathState: String {
    case idle = "Idle"
    case inhaling = "Inhaling"
    case exhaling = "Exhaling"
    case holding = "Holding"
}

class BreathDetector: NSObject, ObservableObject {
    @Published var currentState: BreathState = .idle
    @Published var audioLevel: Float = 0.0
    @Published var isListening = false
    @Published var permissionGranted = false
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    
    // Breath detection parameters
    private var previousLevel: Float = 0.0
    private var levelHistory: [Float] = []
    private let historySize = 10
    
    // Thresholds for breath detection
    private let inhaleThreshold: Float = 0.02
    private let exhaleThreshold: Float = 0.015
    private let silenceThreshold: Float = 0.005
    
    // State tracking
    private var stateStartTime: Date?
    private var isRising = false
    private var isFalling = false
    
    // Callbacks for breath events
    var onInhaleDetected: (() -> Void)?
    var onExhaleDetected: (() -> Void)?
    var onBreathComplete: ((TimeInterval) -> Void)?
    
    override init() {
        super.init()
        checkPermission()
    }
    
    func checkPermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            permissionGranted = true
        case .denied:
            permissionGranted = false
        case .undetermined:
            requestPermission()
        @unknown default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionGranted = granted
            }
        }
    }
    
    func startListening() {
        guard permissionGranted else {
            requestPermission()
            return
        }
        
        setupAudioSession()
        setupAudioEngine()
        
        do {
            try audioEngine?.start()
            isListening = true
            currentState = .holding
            stateStartTime = Date()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func stopListening() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        audioEngine = nil
        isListening = false
        currentState = .idle
        levelHistory.removeAll()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        guard let inputNode = inputNode else { return }
        
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        // Calculate RMS (Root Mean Square) for audio level
        var sum: Float = 0
        for i in 0..<frameLength {
            let sample = channelData[i]
            sum += sample * sample
        }
        let rms = sqrt(sum / Float(frameLength))
        
        DispatchQueue.main.async { [weak self] in
            self?.updateAudioLevel(rms)
        }
    }
    
    private func updateAudioLevel(_ level: Float) {
        audioLevel = level
        
        // Update history
        levelHistory.append(level)
        if levelHistory.count > historySize {
            levelHistory.removeFirst()
        }
        
        // Need enough history for trend detection
        guard levelHistory.count >= 3 else { return }
        
        // Calculate trend
        let recentAvg = levelHistory.suffix(3).reduce(0, +) / 3
        let olderAvg = levelHistory.prefix(3).reduce(0, +) / Float(min(3, levelHistory.count))
        
        let trend = recentAvg - olderAvg
        
        // Detect breath state changes
        detectBreathState(currentLevel: level, trend: trend)
        
        previousLevel = level
    }
    
    private func detectBreathState(currentLevel: Float, trend: Float) {
        let previousState = currentState
        
        // Rising trend with sufficient level indicates inhale
        if trend > 0.002 && currentLevel > inhaleThreshold {
            if currentState != .inhaling {
                currentState = .inhaling
                stateStartTime = Date()
                onInhaleDetected?()
            }
        }
        // Falling trend with sufficient level indicates exhale
        else if trend < -0.002 && currentLevel > exhaleThreshold {
            if currentState != .exhaling {
                // Report the duration of the previous breath phase
                if let startTime = stateStartTime, previousState == .inhaling {
                    let duration = Date().timeIntervalSince(startTime)
                    onBreathComplete?(duration)
                }
                currentState = .exhaling
                stateStartTime = Date()
                onExhaleDetected?()
            }
        }
        // Low level indicates holding/pause
        else if currentLevel < silenceThreshold {
            if currentState != .holding && currentState != .idle {
                // Report the duration of the previous breath phase
                if let startTime = stateStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    onBreathComplete?(duration)
                }
                currentState = .holding
                stateStartTime = Date()
            }
        }
    }
}
