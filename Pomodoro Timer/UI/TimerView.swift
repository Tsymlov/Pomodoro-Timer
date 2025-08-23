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

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            headerSection
            Spacer()
            timerCircle
            Spacer()
            goalSection
            controlButtons
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
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
            canReset: store.canReset,
            timerState: store.timerState,
            sessionColor: store.currentSession.color,
            mainButtonIcon: mainButtonIcon,
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
            VStack(spacing: 4) {
                Image(systemName: "target")
                    .font(Fonts.title2)
                    .foregroundColor(Colors.secondaryText)
                Text("Set a goal for this session")
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
            // Handle settings action
        }) {
            Image(systemName: "gearshape.fill")
                .foregroundColor(store.currentSession.color)
        }
    }

    // MARK: - Computed Properties

    private var mainButtonIcon: String {
        switch store.timerState {
        case .idle, .completed:
            return "play.fill"
        case .running:
            return "pause.fill"
        case .paused:
            return "play.fill"
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
        VStack(spacing: 6) {
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
                    .frame(maxWidth: 200)
                    .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Control Buttons Component
struct ControlButtonsView: View {
    let canReset: Bool
    let timerState: TimerState
    let sessionColor: Color
    let mainButtonIcon: String
    let onReset: () -> Void
    let onMainAction: () -> Void
    let onSkip: () -> Void

    #if os(iOS)
    private let buttonSize: CGFloat = 50
    private let mainButtonSize: CGFloat = 80
    private let buttonSpacing: CGFloat = 20
    #else
    private let buttonSize: CGFloat = 40
    private let mainButtonSize: CGFloat = 64
    private let buttonSpacing: CGFloat = 16
    #endif

    var body: some View {
        HStack(spacing: buttonSpacing) {
            resetButton
            mainActionButton
            skipButton
        }
    }

    private var resetButton: some View {
        Button(action: onReset) {
            Image(systemName: "arrow.counterclockwise")
                .font(Fonts.secondaryButton)
                .foregroundColor(Colors.resetButton)
                .frame(width: buttonSize, height: buttonSize)
                .background(Colors.resetButtonBackground)
                .clipShape(Circle())
        }
        .disabled(!canReset)
    }

    private var mainActionButton: some View {
        Button(action: onMainAction) {
            Image(systemName: mainButtonIcon)
                .font(Fonts.mainButton)
                .foregroundColor(Colors.mainButtonText)
                .frame(width: mainButtonSize, height: mainButtonSize)
                .background(sessionColor)
                .clipShape(Circle())
                .scaleEffect(timerState == .running ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: timerState)
        }
    }

    private var skipButton: some View {
        Button(action: onSkip) {
            Image(systemName: "forward.fill")
                .font(Fonts.secondaryButton)
                .foregroundColor(Colors.skipButton)
                .frame(width: buttonSize, height: buttonSize)
                .background(Colors.skipButtonBackground)
                .clipShape(Circle())
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
        VStack(spacing: 20) {
            headerView
            questionText
            inputField
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 200)
        .onAppear {
            goalText = currentGoal?.text ?? ""
        }
#if os(iOS)
        .presentationDetents([.height(200)])
#endif
    }

    private var headerView: some View {
        HStack {
            Button("Cancel") {
                isPresented = false
                goalText = ""
            }

            Spacer()

            Text("Session Goal")
                .font(Fonts.headline)

            Spacer()

            Button("Save") {
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
        Text("What's your goal?")
            .font(Fonts.title3.weight(.medium))
            .multilineTextAlignment(.center)
            .padding(.top)
    }

    private var inputField: some View {
#if os(iOS)
        AutoFocusTextField(
            text: $goalText,
            placeholder: "Enter your goal...",
            onCommit: {
                guard !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                onSave()
                isPresented = false
                goalText = ""
            }
        )
        .frame(height: 44)
        .padding(.horizontal)
#else
        TextField("Enter your goal...", text: $goalText)
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
