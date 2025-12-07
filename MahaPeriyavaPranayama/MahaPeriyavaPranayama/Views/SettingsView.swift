//
//  SettingsView.swift
//  MahaPeriyavaPranayama
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: BreathingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.15)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Current Exercise Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Current Exercise")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.6))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: viewModel.selectedExercise.icon)
                                        .font(.title2)
                                    Text(viewModel.selectedExercise.name)
                                        .font(.title2.bold())
                                }
                                .foregroundColor(.white)
                                
                                Text(viewModel.selectedExercise.description)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Breathing Pattern Details
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Breathing Pattern")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.6))
                            
                            HStack(spacing: 12) {
                                PatternPhaseView(
                                    title: "Inhale",
                                    duration: viewModel.selectedExercise.inhaleDuration,
                                    color: Color(red: 0.4, green: 0.7, blue: 0.9)
                                )
                                
                                if viewModel.selectedExercise.holdDuration > 0 {
                                    PatternPhaseView(
                                        title: "Hold",
                                        duration: viewModel.selectedExercise.holdDuration,
                                        color: Color(red: 0.6, green: 0.5, blue: 0.9)
                                    )
                                }
                                
                                PatternPhaseView(
                                    title: "Exhale",
                                    duration: viewModel.selectedExercise.exhaleDuration,
                                    color: Color(red: 0.5, green: 0.8, blue: 0.7)
                                )
                                
                                if viewModel.selectedExercise.holdEmptyDuration > 0 {
                                    PatternPhaseView(
                                        title: "Hold",
                                        duration: viewModel.selectedExercise.holdEmptyDuration,
                                        color: Color(red: 0.7, green: 0.5, blue: 0.6)
                                    )
                                }
                            }
                        }
                        
                        // Session Stats
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Session Statistics")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.6))
                            
                            HStack(spacing: 20) {
                                StatView(title: "Cycles", value: "\(viewModel.cycleCount)")
                                StatView(title: "Duration", value: formatDuration(viewModel.totalSessionTime))
                                StatView(title: "Pattern", value: patternRatio)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // All Exercises
                        VStack(alignment: .leading, spacing: 16) {
                            Text("All Exercises")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.6))
                            
                            ForEach(BreathingExercise.allExercises) { exercise in
                                ExerciseRowView(
                                    exercise: exercise,
                                    isSelected: viewModel.selectedExercise == exercise
                                )
                                .onTapGesture {
                                    viewModel.selectExercise(exercise)
                                }
                            }
                        }
                        
                        // About section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Pranayama")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Pranayama is the ancient yogic practice of breath control. Regular practice can help reduce stress, improve focus, and promote overall wellbeing. This app is dedicated to the memory and teachings of Maha Periyava.")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 0.1, green: 0.1, blue: 0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    private var patternRatio: String {
        let parts = [
            viewModel.selectedExercise.inhaleDuration,
            viewModel.selectedExercise.holdDuration,
            viewModel.selectedExercise.exhaleDuration,
            viewModel.selectedExercise.holdEmptyDuration
        ].filter { $0 > 0 }
        
        return parts.map { String(Int($0)) }.joined(separator: ":")
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

struct PatternPhaseView: View {
    let title: String
    let duration: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(duration))s")
                .font(.title2.bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.2))
        .cornerRadius(10)
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseRowView: View {
    let exercise: BreathingExercise
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: exercise.icon)
                .font(.title2)
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(exercise.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0.5, green: 0.8, blue: 0.7))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color(red: 0.5, green: 0.4, blue: 0.7).opacity(0.3) : Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color(red: 0.5, green: 0.4, blue: 0.7) : Color.clear, lineWidth: 1)
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: BreathingViewModel())
    }
}
