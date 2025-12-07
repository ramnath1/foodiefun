//
//  BreathingViewModel.swift
//  MahaPeriyavaPranayama
//

import Foundation
import SwiftUI
import Combine

class BreathingViewModel: ObservableObject {
    @Published var isBreathing = false
    @Published var currentPhase: BreathingPhase = .ready
    @Published var phaseTimeRemaining: Double = 0
    @Published var selectedExercise: BreathingExercise = .boxBreathing
    @Published var showSettings = false
    @Published var cycleCount = 0
    @Published var totalSessionTime: TimeInterval = 0
    @Published var circleScale: CGFloat = 0.6
    
    private var timer: Timer?
    private var phaseTimer: Timer?
    private let tickInterval: Double = 0.1
    
    var currentPhaseText: String {
        switch currentPhase {
        case .inhale:
            return "Breathe In"
        case .hold:
            return "Hold"
        case .exhale:
            return "Breathe Out"
        case .holdEmpty:
            return "Hold Empty"
        case .ready:
            return "Press Play to Begin"
        }
    }
    
    var timerText: String {
        let minutes = Int(totalSessionTime) / 60
        let seconds = Int(totalSessionTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var phaseProgress: Double {
        guard currentPhase != .ready else { return 0 }
        let totalDuration = currentPhaseDuration
        guard totalDuration > 0 else { return 0 }
        return 1 - (phaseTimeRemaining / totalDuration)
    }
    
    var currentPhaseDuration: Double {
        switch currentPhase {
        case .inhale:
            return selectedExercise.inhaleDuration
        case .hold:
            return selectedExercise.holdDuration
        case .exhale:
            return selectedExercise.exhaleDuration
        case .holdEmpty:
            return selectedExercise.holdEmptyDuration
        case .ready:
            return 0
        }
    }
    
    func toggleBreathing() {
        if isBreathing {
            pauseBreathing()
        } else {
            startBreathing()
        }
    }
    
    func startBreathing() {
        isBreathing = true
        if currentPhase == .ready {
            startPhase(.inhale)
        }
        
        // Start session timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.totalSessionTime += 1
        }
    }
    
    func pauseBreathing() {
        isBreathing = false
        timer?.invalidate()
        timer = nil
        phaseTimer?.invalidate()
        phaseTimer = nil
    }
    
    func reset() {
        pauseBreathing()
        currentPhase = .ready
        phaseTimeRemaining = 0
        cycleCount = 0
        totalSessionTime = 0
        withAnimation(.easeInOut(duration: 0.5)) {
            circleScale = 0.6
        }
    }
    
    func selectExercise(_ exercise: BreathingExercise) {
        let wasBreathing = isBreathing
        reset()
        selectedExercise = exercise
        if wasBreathing {
            startBreathing()
        }
    }
    
    private func startPhase(_ phase: BreathingPhase) {
        currentPhase = phase
        phaseTimeRemaining = currentPhaseDuration
        
        // Skip phases with 0 duration
        if phaseTimeRemaining <= 0 {
            moveToNextPhase()
            return
        }
        
        // Animate circle based on phase
        animateCircle(for: phase)
        
        // Start phase countdown
        phaseTimer?.invalidate()
        phaseTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.isBreathing else { return }
            
            self.phaseTimeRemaining -= self.tickInterval
            
            if self.phaseTimeRemaining <= 0 {
                self.moveToNextPhase()
            }
        }
    }
    
    private func animateCircle(for phase: BreathingPhase) {
        let duration = currentPhaseDuration
        
        withAnimation(.easeInOut(duration: duration)) {
            switch phase {
            case .inhale:
                circleScale = 1.0
            case .hold:
                break // Keep current scale
            case .exhale:
                circleScale = 0.6
            case .holdEmpty:
                break // Keep current scale
            case .ready:
                circleScale = 0.6
            }
        }
    }
    
    private func moveToNextPhase() {
        phaseTimer?.invalidate()
        
        guard isBreathing else { return }
        
        let nextPhase: BreathingPhase
        
        switch currentPhase {
        case .inhale:
            nextPhase = selectedExercise.holdDuration > 0 ? .hold : .exhale
        case .hold:
            nextPhase = .exhale
        case .exhale:
            if selectedExercise.holdEmptyDuration > 0 {
                nextPhase = .holdEmpty
            } else {
                cycleCount += 1
                nextPhase = .inhale
            }
        case .holdEmpty:
            cycleCount += 1
            nextPhase = .inhale
        case .ready:
            nextPhase = .inhale
        }
        
        startPhase(nextPhase)
    }
}
