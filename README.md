# Maha Periyava Pranayama 🙏

A beautiful iOS breathing and pranayama app inspired by the teachings of Maha Periyava.

## Features

- 🌬️ **Multiple Breathing Exercises**: Choose from 6 different breathing patterns
  - Basic Breathing (4-4)
  - Box Breathing (4-4-4-4)
  - 4-7-8 Relaxing Breath
  - Energizing Breath (2-2-2)
  - Deep Calm (4-4-8-2)
  - Pranayama Basic (1:4:2 ratio)

- 🎯 **Visual Guidance**: Animated breathing circle that expands and contracts to guide your breath
- ⏱️ **Session Tracking**: Track your total session time and completed breathing cycles
- 🌙 **Beautiful Dark UI**: Calming purple-themed interface designed for relaxation
- ⚙️ **Settings Panel**: View exercise details and switch between different patterns

## Screenshots

The app features a minimalist, meditation-focused design with:
- Animated breathing circle with phase indicators
- Horizontal exercise selector for quick switching
- Real-time countdown timer for each breath phase
- Detailed settings view with exercise information

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.0+

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/ramnath1/MahaPeriyavaPranayama.git
   ```

2. Open `MahaPeriyavaPranayama.xcodeproj` in Xcode

3. Select your target device or simulator

4. Build and run (⌘+R)

## Project Structure

```
MahaPeriyavaPranayama/
├── MahaPeriyavaPranayama/
│   ├── MahaPeriyavaPranayamaApp.swift    # App entry point
│   ├── ContentView.swift                  # Main view
│   ├── Models/
│   │   └── BreathingExercise.swift       # Exercise data models
│   ├── ViewModels/
│   │   └── BreathingViewModel.swift      # Business logic
│   ├── Views/
│   │   ├── BreathingCircleView.swift     # Animated breathing circle
│   │   ├── ExerciseSelectorView.swift    # Exercise picker
│   │   └── SettingsView.swift            # Settings panel
│   └── Assets.xcassets/                  # App assets
└── MahaPeriyavaPranayama.xcodeproj/      # Xcode project
```

## How to Use

1. **Start**: Tap the play button to begin the breathing exercise
2. **Follow**: Watch the circle and follow the breathing instructions
   - Circle expands = Inhale
   - Circle pauses = Hold
   - Circle contracts = Exhale
3. **Switch**: Tap any exercise card at the bottom to change patterns
4. **Settings**: Tap the gear icon to view exercise details and statistics
5. **Reset**: Tap the reset button to start over

## About Pranayama

Pranayama is the ancient yogic practice of breath control. The word comes from Sanskrit:
- **Prana**: Life force, vital energy
- **Ayama**: Control, extension

Regular pranayama practice can help:
- Reduce stress and anxiety
- Improve focus and concentration
- Enhance lung capacity
- Promote relaxation and better sleep
- Balance the nervous system

## Dedication

This app is dedicated to the memory and teachings of **Maha Periyava** (Sri Chandrasekharendra Saraswathi Mahaswamigal), the 68th Jagadguru of Kanchi Kamakoti Peetham, whose teachings on meditation and spiritual practices continue to inspire millions.

## License

This project is open source and available under the MIT License.

---

🙏 *Hara Hara Shankara, Jaya Jaya Shankara* 🙏
