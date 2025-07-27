//
//  ContentView.swift
//  Executive Timer
//
//  Created by Alexey Tsymlov on 23.04.2025.
//

import SwiftUI

private enum Constants {
    static let defaultTime: CGFloat = 1500 // secs. It is 25 mins.
}

struct TimerView: View {
    private let maxTime: CGFloat = Constants.defaultTime
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let strokeStyle = StrokeStyle(lineWidth: 15, lineCap: .round)

    @State private var timerRunning: Bool = false
    @State private var countDownTime: CGFloat = Constants.defaultTime

    private var countdownColor: Color {
        switch countDownTime {
        case 6...: return .green
        case 3...: return .yellow
        default: return .red
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), style: strokeStyle)
            Circle()
                .trim(from: 0, to: 1 - ((maxTime - countDownTime)/maxTime))
                .stroke(countdownColor, style: strokeStyle)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: countDownTime)
        }.frame(width: 300, height: 300)
            .onReceive(timer) { _ in
                guard timerRunning else { return }

                if countDownTime > 0 {
                    countDownTime -= 1
                } else {
                    timerRunning = false
                    countDownTime = maxTime
                }
            }
    }

    func toggle() {
        timerRunning.toggle()
    }
}

#Preview {
    TimerView()
}
