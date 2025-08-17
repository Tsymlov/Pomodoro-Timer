//
//  MainView.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 26.07.2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TimerView()
    }
}

#Preview {
    MainView()
        .environmentObject(Store())
}
