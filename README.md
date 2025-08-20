# Pomodoro Timer

A clean, minimalist Pomodoro Timer app built with SwiftUI using Unidirectional Data Flow (UDF) architecture.

## Features

- **Clean Timer Interface**: Large, easy-to-read timer with progress circle
- **Session Goals**: Set and track goals for each focus session
- **Multiple Session Types**: 
  - Focus sessions (25 minutes)
  - Short breaks (5 minutes) 
  - Long breaks (15 minutes)
- **Automatic Cycling**: Seamlessly transitions between work and break sessions
- **Session Statistics**: Track completed sessions and focus time
- **Local Notifications**: Get notified when sessions complete
- **Cross-Platform**: Works on both iOS and macOS

## Architecture

Built using **Unidirectional Data Flow (UDF)** architecture:

- **State**: Single source of truth for app state
- **Actions**: All user interactions dispatched as actions
- **Reducer**: Pure functions that update state based on actions
- **Store**: ObservableObject that manages state and side effects

## Screenshots

*Screenshots coming soon*

## Getting Started

### Prerequisites

- Xcode 16.0+
- iOS 18.0+ / macOS 15.0+
- Swift 5+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Tsymlov/Pomodoro-Timer.git
```

2. Open `PomodoroTimer.xcodeproj` in Xcode

3. Build and run the project

## How to Use

1. **Start a Session**: Tap the play button to begin a 25-minute focus session
2. **Set a Goal**: Tap "Set a goal for this session" to define what you want to accomplish
3. **Take Breaks**: After completing a focus session, take a 5-minute short break
4. **Long Breaks**: After every 4 focus sessions, take a 15-minute long break
5. **Track Progress**: View your completed sessions and total focus time

## Customization

The timer durations can be customized in `Constants`:

```swift
private enum Constants {
    static let pomodoroDuration: TimeInterval = 25 * 60 // 25 minutes
    static let shortBreakDuration: TimeInterval = 5 * 60 // 5 minutes
    static let longBreakDuration: TimeInterval = 15 * 60 // 15 minutes
}
```

## Project Structure

*Project structure coming soon*

## Technical Details

### Core Components

- **TimerState**: Manages timer states (idle, running, paused, completed)
- **SessionType**: Defines different session types with durations
- **SessionGoal**: Allows users to set goals for focus sessions
- **SessionRecord**: Tracks completed sessions for statistics
- **Settings**: Customizable timer settings and preferences

### Key Features

- **Reactive UI**: SwiftUI with Combine for reactive data flow
- **Background Notifications**: Local notifications when app is backgrounded
- **Data Persistence**: Settings and statistics saved to UserDefaults
- **Cross-Platform**: Conditional compilation for iOS/macOS differences

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Alexey Tsymlov**

- GitHub: [@Tsymlov](https://github.com/Tsymlov)

## Acknowledgments

- Inspired by the Pomodoro Technique® developed by Francesco Cirillo
- Built with SwiftUI and modern iOS development practices

---

If you found this project helpful, please give it a star!
