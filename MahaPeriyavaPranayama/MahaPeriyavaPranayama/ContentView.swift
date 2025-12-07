//
//  ContentView.swift
//  MahaPeriyavaPranayama
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AnulomVilomViewModel()
    
    private let offWhite = Color(red: 0.98, green: 0.97, blue: 0.95)
    private let darkText = Color(red: 0.2, green: 0.2, blue: 0.25)
    private let mutedText = Color(red: 0.4, green: 0.4, blue: 0.45)
    private let buttonBg = Color(red: 0.9, green: 0.89, blue: 0.87)
    
    var body: some View {
        ZStack {
            // Background
            offWhite.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("🙏")
                        .font(.system(size: 40))
                    Text("Anulom Vilom")
                        .font(.system(size: 32, weight: .semibold, design: .serif))
                        .foregroundColor(darkText)
                    Text("Alternate Nostril Breathing")
                        .font(.system(size: 16, weight: .light, design: .serif))
                        .foregroundColor(mutedText)
                }
                .padding(.top, 20)
                
                // Stats row
                HStack(spacing: 30) {
                    SessionStatView(title: "Cycles", value: "\(viewModel.cycleCount)")
                    SessionStatView(title: "Time", value: viewModel.timerText)
                    if viewModel.isActive {
                        SessionStatView(title: "Breath", value: viewModel.currentBreathText)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Breathing Circle
                AnulomVilomCircleView(viewModel: viewModel)
                
                // Phase indicator
                Text(viewModel.currentPhaseText)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(darkText)
                    .animation(.easeInOut, value: viewModel.currentPhase)
                
                // Nostril indicator
                NostrilIndicatorView(viewModel: viewModel)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Average durations (shown when there's data)
                if viewModel.averageInhaleDuration > 0 || viewModel.averageExhaleDuration > 0 {
                    HStack(spacing: 40) {
                        VStack(spacing: 4) {
                            Text("Avg Inhale")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(mutedText)
                            Text(String(format: "%.1fs", viewModel.averageInhaleDuration))
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                .foregroundColor(darkText)
                        }
                        VStack(spacing: 4) {
                            Text("Avg Exhale")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(mutedText)
                            Text(String(format: "%.1fs", viewModel.averageExhaleDuration))
                                .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                .foregroundColor(darkText)
                        }
                    }
                    .padding(.bottom, 10)
                }
                
                // Control buttons
                HStack(spacing: 40) {
                    Button(action: {
                        viewModel.reset()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 24))
                            .foregroundColor(mutedText)
                            .frame(width: 60, height: 60)
                            .background(buttonBg)
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        viewModel.toggleSession()
                    }) {
                        Image(systemName: viewModel.isActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.6, green: 0.4, blue: 0.8),
                                        Color(red: 0.4, green: 0.3, blue: 0.7)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color(red: 0.5, green: 0.3, blue: 0.7).opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    // Microphone indicator
                    ZStack {
                        Circle()
                            .fill(buttonBg)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: viewModel.breathDetector.isListening ? "mic.fill" : "mic")
                            .font(.system(size: 24))
                            .foregroundColor(viewModel.breathDetector.isListening ? Color(red: 0.5, green: 0.4, blue: 0.7) : mutedText)
                        
                        // Audio level indicator
                        if viewModel.breathDetector.isListening {
                            Circle()
                                .stroke(Color(red: 0.5, green: 0.4, blue: 0.7), lineWidth: 2)
                                .frame(width: 60, height: 60)
                                .scaleEffect(1 + CGFloat(viewModel.breathDetector.audioLevel) * 5)
                                .opacity(Double(1 - viewModel.breathDetector.audioLevel * 3))
                                .animation(.easeOut(duration: 0.1), value: viewModel.breathDetector.audioLevel)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .alert("Microphone Access Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable microphone access in Settings to detect your breathing.")
        }
    }
}

struct SessionStatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
        }
        .frame(minWidth: 70)
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.95, green: 0.94, blue: 0.92))
        )
    }
}

struct AnulomVilomCircleView: View {
    @ObservedObject var viewModel: AnulomVilomViewModel
    
    private var phaseColor: Color {
        switch viewModel.currentPhase {
        case .inhaleRight, .inhaleLeft:
            return Color(red: 0.4, green: 0.7, blue: 0.9)
        case .exhaleLeft, .exhaleRight:
            return Color(red: 0.5, green: 0.8, blue: 0.7)
        case .ready:
            return Color(red: 0.5, green: 0.4, blue: 0.8)
        }
    }
    
    private var phaseIcon: String {
        switch viewModel.currentPhase {
        case .inhaleRight, .inhaleLeft:
            return "arrow.down.circle"
        case .exhaleLeft, .exhaleRight:
            return "arrow.up.circle"
        case .ready:
            return "play.circle"
        }
    }
    
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
                    .frame(width: 180 + CGFloat(index) * 25, height: 180 + CGFloat(index) * 25)
                    .scaleEffect(viewModel.circleScale + CGFloat(index) * 0.05)
                    .opacity(viewModel.isActive ? 0.8 : 0.4)
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
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)
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
                .frame(width: 160, height: 160)
                .scaleEffect(viewModel.circleScale)
            
            // Center icon
            VStack(spacing: 8) {
                Image(systemName: phaseIcon)
                    .font(.system(size: 36))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.9))
                
                if viewModel.isActive {
                    Text(viewModel.currentBreathText)
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3).opacity(0.8))
                }
            }
            .scaleEffect(viewModel.circleScale * 0.9)
        }
        .frame(width: 260, height: 260)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
