//
//  ContentView.swift
//  MahaPeriyavaPranayama
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BreathingViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - off-white
                Color(red: 0.98, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🙏")
                            .font(.system(size: 40))
                        Text("Maha Periyava")
                            .font(.system(size: 28, weight: .light, design: .serif))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        Text("Pranayama")
                            .font(.system(size: 36, weight: .semibold, design: .serif))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Breathing Circle
                    BreathingCircleView(viewModel: viewModel)
                    
                    // Phase indicator
                    Text(viewModel.currentPhaseText)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.35))
                        .animation(.easeInOut, value: viewModel.currentPhase)
                    
                    // Timer display
                    Text(viewModel.timerText)
                        .font(.system(size: 48, weight: .thin, design: .monospaced))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                    
                    Spacer()
                    
                    // Exercise selector
                    ExerciseSelectorView(viewModel: viewModel)
                        .padding(.horizontal)
                    
                    // Control buttons
                    HStack(spacing: 40) {
                        Button(action: {
                            viewModel.reset()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                                .frame(width: 60, height: 60)
                                .background(Color(red: 0.9, green: 0.89, blue: 0.87))
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            viewModel.toggleBreathing()
                        }) {
                            Image(systemName: viewModel.isBreathing ? "pause.fill" : "play.fill")
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
                        
                        Button(action: {
                            viewModel.showSettings.toggle()
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.45))
                                .frame(width: 60, height: 60)
                                .background(Color(red: 0.9, green: 0.89, blue: 0.87))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
