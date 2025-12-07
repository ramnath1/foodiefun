//
//  ExerciseSelectorView.swift
//  MahaPeriyavaPranayama
//

import SwiftUI

struct ExerciseSelectorView: View {
    @ObservedObject var viewModel: BreathingViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(BreathingExercise.allExercises) { exercise in
                    ExerciseCardView(
                        exercise: exercise,
                        isSelected: viewModel.selectedExercise == exercise
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.selectExercise(exercise)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct ExerciseCardView: View {
    let exercise: BreathingExercise
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: exercise.icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            
            Text(exercise.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .lineLimit(1)
            
            // Duration indicator
            Text(durationText)
                .font(.system(size: 10, weight: .light))
                .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.4))
        }
        .frame(width: 90, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? 
                    Color(red: 0.5, green: 0.4, blue: 0.7) :
                    Color.white.opacity(0.1)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isSelected ? 
                        Color.white.opacity(0.3) :
                        Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
    
    private var durationText: String {
        let parts = [
            exercise.inhaleDuration,
            exercise.holdDuration,
            exercise.exhaleDuration,
            exercise.holdEmptyDuration
        ].filter { $0 > 0 }
        
        return parts.map { String(Int($0)) }.joined(separator: "-")
    }
}

struct ExerciseSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            ExerciseSelectorView(viewModel: BreathingViewModel())
        }
    }
}
