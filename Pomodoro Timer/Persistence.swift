//
//  PersistenceManager.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 17.08.2025.
//

import Foundation

enum PersistenceKeys {
    static let appState = "AppState"
    static let settings = "Settings"
}

final class Persistence {
    static let shared = Persistence()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var saveTimer: Timer?
    private var pendingState: AppState?
    
    private init() {
        encoder.outputFormatting = .sortedKeys
    }
    
    // MARK: - AppState Management
    func loadAppState() -> AppState? {
        guard let data = UserDefaults.standard.data(forKey: PersistenceKeys.appState) else { 
            return nil 
        }
        
        do {
            var state = try decoder.decode(AppState.self, from: data)
            // Clean up runtime state
            state.isGoalInputPresented = false
            state.backgroundTime = nil
            
            // Reset timer if it was running, paused, or completed
            if state.timerState == .running || state.timerState == .paused || state.timerState == .completed {
                state.timerState = .idle
                state.sessionEndTime = nil
                state.timeRemaining = state.getCurrentSessionDuration()
            }
            
            return state
        } catch {
            print("[Persistence] Failed to load AppState: \(error)")
            return nil
        }
    }
    
    func saveAppState(_ state: AppState, immediately: Bool = false) {
        if immediately {
            performSave(state)
        } else {
            scheduleSave(state)
        }
    }
    
    private func scheduleSave(_ state: AppState) {
        pendingState = state
        
        // Cancel existing timer
        saveTimer?.invalidate()
        
        // Schedule new save after 1 second of inactivity
        saveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.performSave(state)
        }
    }
    
    private func performSave(_ state: AppState) {
        do {
            let data = try encoder.encode(state)
            UserDefaults.standard.set(data, forKey: PersistenceKeys.appState)
            pendingState = nil
        } catch {
            print("[Persistence] Failed to save AppState: \(error)")
        }
    }
    
    // MARK: - Settings Management
    func loadSettings() -> Settings {
        guard let data = UserDefaults.standard.data(forKey: PersistenceKeys.settings) else {
            return Settings()
        }
        
        do {
            return try decoder.decode(Settings.self, from: data)
        } catch {
            print("[Persistence] Failed to load Settings: \(error)")
            return Settings()
        }
    }
    
    func saveSettings(_ settings: Settings) {
        do {
            let data = try encoder.encode(settings)
            UserDefaults.standard.set(data, forKey: PersistenceKeys.settings)
        } catch {
            print("[Persistence] Failed to save Settings: \(error)")
        }
    }
    
    // MARK: - Cleanup
    func forceSaveIfPending() {
        if let state = pendingState {
            saveTimer?.invalidate()
            performSave(state)
        }
    }
    
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: PersistenceKeys.appState)
        UserDefaults.standard.removeObject(forKey: PersistenceKeys.settings)
    }
    
    deinit {
        forceSaveIfPending()
    }
}