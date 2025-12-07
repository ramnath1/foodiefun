//
//  BreathingExercise.swift
//  MahaPeriyavaPranayama
//

import Foundation

enum BreathingPhase: String {
    case inhale = "Inhale"
    case hold = "Hold"
    case exhale = "Exhale"
    case holdEmpty = "Hold"
    case ready = "Ready"
}

struct BreathingExercise: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let inhaleDuration: Double
    let holdDuration: Double
    let exhaleDuration: Double
    let holdEmptyDuration: Double
    let icon: String
    
    var totalCycleDuration: Double {
        inhaleDuration + holdDuration + exhaleDuration + holdEmptyDuration
    }
    
    static func == (lhs: BreathingExercise, rhs: BreathingExercise) -> Bool {
        lhs.name == rhs.name
    }
    
    // Predefined breathing exercises
    static let basicBreathing = BreathingExercise(
        name: "Basic Breathing",
        description: "Simple 4-4 breathing pattern for beginners",
        inhaleDuration: 4,
        holdDuration: 0,
        exhaleDuration: 4,
        holdEmptyDuration: 0,
        icon: "wind"
    )
    
    static let boxBreathing = BreathingExercise(
        name: "Box Breathing",
        description: "4-4-4-4 pattern for stress relief and focus",
        inhaleDuration: 4,
        holdDuration: 4,
        exhaleDuration: 4,
        holdEmptyDuration: 4,
        icon: "square"
    )
    
    static let relaxingBreath = BreathingExercise(
        name: "4-7-8 Relaxing",
        description: "Dr. Weil's relaxing breath technique",
        inhaleDuration: 4,
        holdDuration: 7,
        exhaleDuration: 8,
        holdEmptyDuration: 0,
        icon: "moon.stars"
    )
    
    static let energizingBreath = BreathingExercise(
        name: "Energizing Breath",
        description: "Quick breathing to increase energy",
        inhaleDuration: 2,
        holdDuration: 2,
        exhaleDuration: 2,
        holdEmptyDuration: 0,
        icon: "bolt"
    )
    
    static let deepCalm = BreathingExercise(
        name: "Deep Calm",
        description: "Extended exhale for deep relaxation",
        inhaleDuration: 4,
        holdDuration: 4,
        exhaleDuration: 8,
        holdEmptyDuration: 2,
        icon: "leaf"
    )
    
    static let pranayamaBasic = BreathingExercise(
        name: "Pranayama Basic",
        description: "Traditional yogic breathing 1:4:2 ratio",
        inhaleDuration: 4,
        holdDuration: 16,
        exhaleDuration: 8,
        holdEmptyDuration: 0,
        icon: "sparkles"
    )
    
    static let allExercises: [BreathingExercise] = [
        .basicBreathing,
        .boxBreathing,
        .relaxingBreath,
        .energizingBreath,
        .deepCalm,
        .pranayamaBasic
    ]
}
