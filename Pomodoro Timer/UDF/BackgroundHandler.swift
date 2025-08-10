//
//  BackgroundHandler.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 10.08.2025.
//

import Foundation
import UIKit

@MainActor
final class BackgroundHandler {
    private weak var store: Store?
    
    init(store: Store) {
        self.store = store
        setupObservers()
    }
    
    private func setupObservers() {
#if os(iOS)
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.store?.send(.enterBackground)
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.store?.send(.enterForeground)
            }
        }
#endif
    }
    
    deinit {
#if os(iOS)
        NotificationCenter.default.removeObserver(self)
#endif
    }
}