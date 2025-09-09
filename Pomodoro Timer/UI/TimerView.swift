//
//  TimerView.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 27.07.2025.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var store: Store
    @State private var goalText = ""
    @State private var showingGoalInput = false
    @State private var showingSettings = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: Constants.timerViewSpacing) {
            headerSection
            Spacer()
            timerCircle
            Spacer()
            goalSection
            controlButtons
            Spacer()
        }
        .padding(.horizontal, Constants.timerViewPaddingHorizontal)
        .padding(.vertical, Constants.timerViewPaddingVertical)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.appBackground)
        .sheet(isPresented: $showingGoalInput) {
            GoalInputSheet(
                goalText: $goalText,
                isPresented: $showingGoalInput,
                currentGoal: store.currentGoal,
                onSave: { store.send(.setGoal(goalText)) }
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(store: store)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Spacer()
            settingsButton
        }
        .padding(.horizontal)
    }

    // MARK: - Goal Section
    private var goalSection: some View {
        Group {
            if let goal = store.currentGoal {
                goalDisplay(goal)
            } else {
                goalPlaceholder
            }
        }
    }

    // MARK: - Timer Circle
    private var timerCircle: some View {
        TimerCircleView(
            progress: store.progress,
            formattedTime: store.formattedTime,
            sessionColor: store.currentSession.color,
            progressBackgroundColor: store.currentSession.progressBackgroundColor,
            cyclesDisplay: store.todayPomodorosCyclesDisplay,
            showCycles: store.statistics.todayStats.completedPomodoros > 0
        )
    }

    // MARK: - Control Buttons
    private var controlButtons: some View {
        ControlButtonsView(
            timerState: store.timerState,
            currentSession: store.currentSession,
            sessionColor: store.currentSession.color,
            onReset: { store.send(.reset) },
            onMainAction: mainButtonAction,
            onSkip: skipButtonAction
        )
    }

    // MARK: - Goal Display
    private func goalDisplay(_ goal: SessionGoal) -> some View {
        Button(action: {
            showingGoalInput = true
        }) {
            Text(goal.text)
                .font(Fonts.body)
                .foregroundColor(Colors.primaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .fill(store.currentSession.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.cornerRadius)
                                .stroke(store.currentSession.color, lineWidth: Constants.borderWidth)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    // MARK: - Goal Placeholder
    private var goalPlaceholder: some View {
        Button(action: {
            showingGoalInput = true
        }) {
            VStack(spacing: Constants.goalPlaceholderSpacing) {
                Image(systemName: Strings.Icons.target)
                    .font(Fonts.title2)
                    .foregroundColor(Colors.secondaryText)
                Text(Strings.Timer.setGoal)
                    .font(Fonts.body)
                    .foregroundColor(Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(store.currentSession.borderColor, style: StrokeStyle(lineWidth: Constants.borderWidth, dash: Constants.dashPattern))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    // MARK: - Settings Button
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            Image(systemName: Strings.Icons.gearshape)
                .foregroundColor(store.currentSession.color)
        }
    }

    // MARK: - Actions
    private func mainButtonAction() {
        switch store.timerState {
        case .idle, .completed:
            store.send(.start)
        case .running:
            store.send(.pause)
        case .paused:
            store.send(.resume)
        }
    }

    private func skipButtonAction() {
        switch store.currentSession {
        case .pomodoro:
            store.send(.skipToBreak)
        case .shortBreak, .longBreak:
            store.send(.skipToPomodoro)
        }
    }
}

// MARK: - Timer Circle Component
struct TimerCircleView: View {
    let progress: Double
    let formattedTime: String
    let sessionColor: Color
    let progressBackgroundColor: Color
    let cyclesDisplay: String
    let showCycles: Bool

    private let circleSize: CGFloat = Constants.timerCircleSize
    private let lineWidth: CGFloat = Constants.timerLineWidth

    var body: some View {
        ZStack {
            backgroundCircle
            progressCircle
            timeDisplay
        }
    }

    private var backgroundCircle: some View {
        Circle()
            .stroke(progressBackgroundColor, lineWidth: lineWidth)
            .frame(width: circleSize, height: circleSize)
    }

    private var progressCircle: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                sessionColor,
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .frame(width: circleSize, height: circleSize)
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut, value: progress)
    }

    private var timeDisplay: some View {
        VStack(spacing: Constants.timerCyclesSpacing) {
            Text(formattedTime)
                #if os(iOS)
                .font(Fonts.timerDisplay)
                #else
                .font(Fonts.timerDisplay)
                #endif
                .foregroundColor(sessionColor)

            if showCycles {
                Text(cyclesDisplay)
                    .font(Fonts.timerCycles)
                    .foregroundColor(sessionColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: Constants.timerCyclesMaxWidth)
                    .padding(.top, Constants.timerCyclesPaddingTop)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Control Buttons Component
struct ControlButtonsView: View {
    let timerState: TimerState
    let currentSession: SessionType
    let sessionColor: Color
    let onReset: () -> Void
    let onMainAction: () -> Void
    let onSkip: () -> Void

    private let buttonSize: CGFloat = Constants.controlButtonSize
    private let mainButtonSize: CGFloat = Constants.mainControlButtonSize
    private let buttonSpacing: CGFloat = Constants.controlButtonSpacing

    var body: some View {
        HStack(spacing: buttonSpacing) {
            buttonGroup
        }
    }
    
    @ViewBuilder
    private var buttonGroup: some View {
        switch buttonLayout {
        case .idlePomodoro:
            startFocusButtonLarge
            startBreakButtonLarge
        case .activePomodoro:
            stopButtonLarge
            startBreakButtonLarge
        case .pausedPomodoro:
            stopButton
            startFocusButton
        case .breakSession:
            startFocusButtonForBreak
            stopButtonLarge
        }
    }
    
    private enum ButtonLayout {
        case idlePomodoro
        case activePomodoro  // for both running and completed
        case pausedPomodoro
        case breakSession
    }
    
    private var buttonLayout: ButtonLayout {
        if currentSession == .pomodoro {
            switch timerState {
            case .idle:
                return .idlePomodoro
            case .running, .completed:
                return .activePomodoro
            case .paused:
                return .pausedPomodoro
            }
        } else {
            // For break sessions (shortBreak, longBreak)
            return .breakSession
        }
    }

    private var stopButton: some View {
        Button(action: onReset) {
            Image(systemName: Strings.Icons.stopFill)
                .font(Fonts.mainButton)
                .foregroundColor(Colors.mainButtonText)
                .frame(width: mainButtonSize, height: mainButtonSize)
                .background(Color.red)
                .clipShape(Circle())
        }
    }
    
    private var startBreakButton: some View {
        Button(action: onSkip) {
            Image(systemName: Strings.Icons.cupAndSaucerFill)
                .font(Fonts.mainButton)
                .foregroundColor(Colors.mainButtonText)
                .frame(width: mainButtonSize, height: mainButtonSize)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
    
    private var startFocusButton: some View {
        Button(action: onMainAction) {
            Image(systemName: Strings.Icons.playFill)
                .font(Fonts.mainButton)
                .foregroundColor(Colors.mainButtonText)
                .frame(width: mainButtonSize, height: mainButtonSize)
                .background(Color.red)
                .clipShape(Circle())
        }
    }
    
    private var startFocusButtonLarge: some View {
        Button(action: onMainAction) {
            Text(Strings.Timer.startFocus)
                .font(.headline)
                .foregroundColor(Colors.mainButtonText)
                .padding(.horizontal, Constants.controlButtonPaddingHorizontal)
                .padding(.vertical, Constants.controlButtonPaddingVertical)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: Constants.controlButtonCornerRadius))
        }
    }
    
    private var startBreakButtonLarge: some View {
        Button(action: onSkip) {
            Text(Strings.Timer.startBreak)
                .font(.headline)
                .foregroundColor(Colors.mainButtonText)
                .padding(.horizontal, Constants.controlButtonPaddingHorizontal)
                .padding(.vertical, Constants.controlButtonPaddingVertical)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: Constants.controlButtonCornerRadius))
        }
    }
    
    private var stopButtonLarge: some View {
        Button(action: onReset) {
            Text(Strings.Timer.stop)
                .font(.headline)
                .foregroundColor(Colors.mainButtonText)
                .padding(.horizontal, Constants.controlButtonPaddingHorizontal)
                .padding(.vertical, Constants.controlButtonPaddingVertical)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: Constants.controlButtonCornerRadius))
        }
    }
    
    private var startFocusButtonForBreak: some View {
        Button(action: onSkip) {
            Text(Strings.Timer.startFocus)
                .font(.headline)
                .foregroundColor(Colors.mainButtonText)
                .padding(.horizontal, Constants.controlButtonPaddingHorizontal)
                .padding(.vertical, Constants.controlButtonPaddingVertical)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: Constants.controlButtonCornerRadius))
        }
    }
}

// MARK: - Goal Input Sheet Component
struct GoalInputSheet: View {
    @Binding var goalText: String
    @Binding var isPresented: Bool
    let currentGoal: SessionGoal?
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: Constants.goalInputSheetSpacing) {
            headerView
            questionText
            inputField
            Spacer()
        }
        .padding()
        .frame(minWidth: Constants.goalInputSheetMinWidth, minHeight: Constants.goalInputSheetMinHeight)
        .onAppear {
            goalText = currentGoal?.text ?? ""
        }
#if os(iOS)
        .presentationDetents([.height(Constants.goalInputSheetDetentHeight)])
#endif
    }

    private var headerView: some View {
        HStack {
            Button(Strings.Timer.cancel) {
                isPresented = false
                goalText = ""
            }

            Spacer()

            Text(Strings.Timer.sessionGoal)
                .font(Fonts.headline)

            Spacer()

            Button(Strings.Timer.save) {
                guard !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                onSave()
                isPresented = false
                goalText = ""
            }
            .disabled(goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }

    private var questionText: some View {
        Text(Strings.Timer.whatsYourGoal)
            .font(Fonts.title3.weight(.medium))
            .multilineTextAlignment(.center)
            .padding(.top)
    }

    private var inputField: some View {
#if os(iOS)
        AutoFocusTextField(
            text: $goalText,
            placeholder: Strings.Timer.enterYourGoal,
            onCommit: {
                guard !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                onSave()
                isPresented = false
                goalText = ""
            }
        )
        .frame(height: Constants.goalInputTextFieldHeight)
        .padding(.horizontal)
#else
        TextField(Strings.Timer.enterYourGoal, text: $goalText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .onSubmit {
                guard !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                onSave()
                isPresented = false
                goalText = ""
            }
#endif
    }
}

// MARK: - Preview
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
            .environmentObject(Store())
    }
}
