//
//  BreathingCircleView.swift
//  MahaPeriyavaPranayama
//

import SwiftUI

struct BreathingCircleView: View {
    @ObservedObject var viewModel: BreathingViewModel
    
    var body: some View {
        ZStack {
            // Outer glow rings
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.3 - Double(index) * 0.1),
                                Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.2 - Double(index) * 0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 200 + CGFloat(index) * 30, height: 200 + CGFloat(index) * 30)
                    .scaleEffect(viewModel.circleScale + CGFloat(index) * 0.05)
                    .opacity(viewModel.isBreathing ? 0.8 : 0.4)
            }
            
            // Main breathing circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            phaseColor.opacity(0.8),
                            phaseColor.opacity(0.4),
                            phaseColor.opacity(0.1)
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(viewModel.circleScale)
                .shadow(color: phaseColor.opacity(0.5), radius: 30, x: 0, y: 0)
            
            // Inner circle with border
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.3, green: 0.3, blue: 0.4).opacity(0.6),
                            Color(red: 0.3, green: 0.3, blue: 0.4).opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 180, height: 180)
                .scaleEffect(viewModel.circleScale)
            
            // Center icon
            VStack(spacing: 8) {
                Image(systemName: phaseIcon)
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.9))
                
                if viewModel.currentPhase != .ready {
                    Text("\(Int(ceil(viewModel.phaseTimeRemaining)))")
                        .font(.system(size: 28, weight: .light, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.8))
                }
            }
            .scaleEffect(viewModel.circleScale * 0.9)
        }
        .frame(width: 280, height: 280)
    }
    
    private var phaseColor: Color {
        switch viewModel.currentPhase {
        case .inhale:
            return Color(red: 0.4, green: 0.7, blue: 0.9)
        case .hold, .holdEmpty:
            return Color(red: 0.6, green: 0.5, blue: 0.9)
        case .exhale:
            return Color(red: 0.5, green: 0.8, blue: 0.7)
        case .ready:
            return Color(red: 0.5, green: 0.4, blue: 0.8)
        }
    }
    
    private var phaseIcon: String {
        switch viewModel.currentPhase {
        case .inhale:
            return "arrow.down.circle"
        case .hold, .holdEmpty:
            return "pause.circle"
        case .exhale:
            return "arrow.up.circle"
        case .ready:
            return "play.circle"
        }
    }
}

struct BreathingCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
            BreathingCircleView(viewModel: BreathingViewModel())
        }
    }
}
