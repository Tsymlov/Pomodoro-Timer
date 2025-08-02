//
//  TimerView.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 27.07.2025.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var timer = PomodoroTimer()
    private let strokeWidth: CGFloat = 15

    var body: some View {
        ZStack {
            // Фоновый круг
            Circle()
                .stroke(lineWidth: strokeWidth)
                .opacity(0.3)
                .foregroundColor(.gray)

            // Прогресс таймера
            Circle()
                .trim(from: 0.0, to: CGFloat(1 - (timer.countDownTime / timer.duration)))
                .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(.red)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear, value: timer.countDownTime)

            // Время и кнопки
            VStack {
                Text(timeString(from: timer.countDownTime))
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .padding(.bottom, 30)

                HStack(spacing: 40) {
                    Button(action: {
                        timer.toggle()
                    }) {
                        Image(systemName: timer.isRunning ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }

                    Button(action: {
                        timer.reset()
                    }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .foregroundColor(.white)
    }

    private func timeString(from seconds: CGFloat) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

#Preview {
    TimerView()
}
