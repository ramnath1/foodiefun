//
//  NostrilIndicatorView.swift
//  MahaPeriyavaPranayama
//

import SwiftUI

struct NostrilIndicatorView: View {
    @ObservedObject var viewModel: AnulomVilomViewModel
    
    private let darkText = Color(red: 0.2, green: 0.2, blue: 0.25)
    private let mutedText = Color(red: 0.4, green: 0.4, blue: 0.45)
    private let activeColor = Color(red: 0.5, green: 0.4, blue: 0.7)
    private let inactiveColor = Color(red: 0.85, green: 0.84, blue: 0.82)
    
    var body: some View {
        VStack(spacing: 20) {
            // Nose visualization with nostrils
            HStack(spacing: 40) {
                // Left nostril
                NostrilView(
                    side: .left,
                    isActive: viewModel.activeNostril == .left,
                    isInhale: viewModel.currentPhase == .inhaleLeft,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor
                )
                
                // Right nostril
                NostrilView(
                    side: .right,
                    isActive: viewModel.activeNostril == .right,
                    isInhale: viewModel.currentPhase == .inhaleRight,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor
                )
            }
            
            // Instruction text
            Text(viewModel.nostrilInstruction)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(darkText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.95, green: 0.94, blue: 0.92))
        )
    }
}

struct NostrilView: View {
    let side: Nostril
    let isActive: Bool
    let isInhale: Bool
    let activeColor: Color
    let inactiveColor: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Nostril circle with arrow
            ZStack {
                // Background circle
                Circle()
                    .fill(isActive ? activeColor : inactiveColor)
                    .frame(width: 60, height: 60)
                
                // Arrow indicating direction
                if isActive {
                    Image(systemName: isInhale ? "arrow.down" : "arrow.up")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Closed indicator when inactive
                if !isActive {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isActive)
            
            // Label
            Text(side.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isActive ? activeColor : Color(red: 0.5, green: 0.5, blue: 0.5))
        }
    }
}

struct NostrilIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
            NostrilIndicatorView(viewModel: AnulomVilomViewModel())
        }
    }
}
