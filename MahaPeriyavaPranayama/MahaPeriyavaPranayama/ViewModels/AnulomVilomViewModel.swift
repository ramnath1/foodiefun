//
//  AnulomVilomViewModel.swift
//  MahaPeriyavaPranayama
//

import Foundation
import SwiftUI
import Combine

enum Nostril: String {
    case right = "Right"
    case left = "Left"
}

enum AnulomVilomPhase: String {
    case ready = "Ready to Begin"
    case inhaleRight = "Inhale (Right)"
    case exhaleLeft = "Exhale (Left)"
    case inhaleLeft = "Inhale (Left)"
    case exhaleRight = "Exhale (Right)"
}

struct BreathRecord: Identifiable {
    let id = UUID()
    let phase: AnulomVilomPhase
    let duration: TimeInterval
    let timestamp: Date
}

class AnulomVilomViewModel: ObservableObject {
    // Published state
    @Published var isActive = false
    @Published var currentPhase: AnulomVilomPhase = .ready
    @Published var activeNostril: Nostril = .right
    @Published var cycleCount = 0
    @Published var currentBreathDuration: TimeInterval = 0
    @Published var totalSessionTime: TimeInterval = 0
    @Published var breathRecords: [BreathRecord] = []
    @Published var circleScale: CGFloat = 0.6
    @Published var showPermissionAlert = false
    
    // Breath detector
    let breathDetector = BreathDetector()
    
    // Average durations
    @Published var averageInhaleDuration: TimeInterval = 0
    @Published var averageExhaleDuration: TimeInterval = 0
    
    // Internal tracking
    private var sessionTimer: Timer?
    private var breathTimer: Timer?
    private var phaseStartTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    var currentPhaseText: String {
        return currentPhase.rawValue
    }
    
    var nostrilInstruction: String {
        switch currentPhase {
        case .ready:
            return "Close left nostril, breathe through right"
        case .inhaleRight:
            return "Close left nostril\nInhale through RIGHT"
        case .exhaleLeft:
            return "Close right nostril\nExhale through LEFT"
        case .inhaleLeft:
            return "Close right nostril\nInhale through LEFT"
        case .exhaleRight:
            return "Close left nostril\nExhale through RIGHT"
        }
    }
    
    var timerText: String {
        let minutes = Int(totalSessionTime) / 60
        let seconds = Int(totalSessionTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var currentBreathText: String {
        return String(format: "%.1fs", currentBreathDuration)
    }
    
    init() {
        setupBreathDetectorCallbacks()
        observeBreathDetector()
    }
    
    private func setupBreathDetectorCallbacks() {
        breathDetector.onInhaleDetected = { [weak self] in
            self?.handleInhaleDetected()
        }
        
        breathDetector.onExhaleDetected = { [weak self] in
            self?.handleExhaleDetected()
        }
        
        breathDetector.onBreathComplete = { [weak self] duration in
            self?.recordBreathDuration(duration)
        }
    }
    
    private func observeBreathDetector() {
        breathDetector.$permissionGranted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] granted in
                if !granted && self?.isActive == true {
                    self?.showPermissionAlert = true
                }
            }
            .store(in: &cancellables)
    }
    
    func toggleSession() {
        if isActive {
            stopSession()
        } else {
            startSession()
        }
    }
    
    func startSession() {
        guard breathDetector.permissionGranted else {
            breathDetector.requestPermission()
            showPermissionAlert = true
            return
        }
        
        isActive = true
        currentPhase = .inhaleRight
        activeNostril = .right
        phaseStartTime = Date()
        
        // Start breath detector
        breathDetector.startListening()
        
        // Start session timer
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.totalSessionTime += 1
        }
        
        // Start breath duration timer
        breathTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.phaseStartTime else { return }
            self.currentBreathDuration = Date().timeIntervalSince(startTime)
        }
        
        // Animate circle for inhale
        animateCircle(expanding: true)
    }
    
    func stopSession() {
        isActive = false
        currentPhase = .ready
        
        // Stop timers
        sessionTimer?.invalidate()
        sessionTimer = nil
        breathTimer?.invalidate()
        breathTimer = nil
        
        // Stop breath detector
        breathDetector.stopListening()
        
        // Reset circle
        withAnimation(.easeInOut(duration: 0.5)) {
            circleScale = 0.6
        }
    }
    
    func reset() {
        stopSession()
        cycleCount = 0
        totalSessionTime = 0
        currentBreathDuration = 0
        breathRecords.removeAll()
        averageInhaleDuration = 0
        averageExhaleDuration = 0
    }
    
    private func handleInhaleDetected() {
        guard isActive else { return }
        
        // Transition to appropriate inhale phase based on current state
        switch currentPhase {
        case .ready, .exhaleLeft:
            // After exhaling left, next inhale is from left
            transitionToPhase(.inhaleLeft)
        case .exhaleRight:
            // After exhaling right, next inhale is from right (new cycle starts)
            transitionToPhase(.inhaleRight)
        default:
            break
        }
    }
    
    private func handleExhaleDetected() {
        guard isActive else { return }
        
        // Transition to appropriate exhale phase based on current state
        switch currentPhase {
        case .inhaleRight:
            // After inhaling right, exhale through left
            transitionToPhase(.exhaleLeft)
        case .inhaleLeft:
            // After inhaling left, exhale through right
            transitionToPhase(.exhaleRight)
            // Completing exhale right completes one full cycle
            cycleCount += 1
        default:
            break
        }
    }
    
    private func transitionToPhase(_ newPhase: AnulomVilomPhase) {
        currentPhase = newPhase
        phaseStartTime = Date()
        currentBreathDuration = 0
        
        // Update active nostril
        switch newPhase {
        case .inhaleRight, .exhaleRight:
            activeNostril = .right
        case .inhaleLeft, .exhaleLeft:
            activeNostril = .left
        case .ready:
            activeNostril = .right
        }
        
        // Animate circle
        let isInhale = newPhase == .inhaleRight || newPhase == .inhaleLeft
        animateCircle(expanding: isInhale)
    }
    
    private func animateCircle(expanding: Bool) {
        withAnimation(.easeInOut(duration: 4.0)) {
            circleScale = expanding ? 1.0 : 0.6
        }
    }
    
    private func recordBreathDuration(_ duration: TimeInterval) {
        guard isActive, duration > 0.5 else { return } // Ignore very short detections
        
        let record = BreathRecord(phase: currentPhase, duration: duration, timestamp: Date())
        breathRecords.append(record)
        
        // Update averages
        updateAverages()
    }
    
    private func updateAverages() {
        let inhaleRecords = breathRecords.filter {
            $0.phase == .inhaleRight || $0.phase == .inhaleLeft
        }
        let exhaleRecords = breathRecords.filter {
            $0.phase == .exhaleLeft || $0.phase == .exhaleRight
        }
        
        if !inhaleRecords.isEmpty {
            averageInhaleDuration = inhaleRecords.map { $0.duration }.reduce(0, +) / Double(inhaleRecords.count)
        }
        
        if !exhaleRecords.isEmpty {
            averageExhaleDuration = exhaleRecords.map { $0.duration }.reduce(0, +) / Double(exhaleRecords.count)
        }
    }
}
