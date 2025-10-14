//
//  TimerViewModel.swift
//  SmartPath
//
//  Created by Assistant on 10/14/25.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

@MainActor
class TimerViewModel: ObservableObject {
    enum Phase: String { case focus, shortBreak, longBreak }

    // Settings persisted in user defaults
    @AppStorage("timer.focusMinutes") var focusMinutes: Int = 25
    @AppStorage("timer.shortBreakMinutes") var shortBreakMinutes: Int = 5
    @AppStorage("timer.longBreakMinutes") var longBreakMinutes: Int = 15
    @AppStorage("timer.longBreakInterval") var longBreakInterval: Int = 4
    @AppStorage("timer.alertSoundEnabled") var alertSoundEnabled: Bool = true

    @Published var phase: Phase = .focus
    @Published var isRunning: Bool = false
    @Published var secondsRemaining: Int = 0
    @Published var completedFocusCount: Int = 0
    @Published var selectedTaskIds: Set<String> = []

    private var timer: Timer?

    init() {
        resetTimer(for: .focus)
    }

    func toggle() {
        isRunning.toggle()
        if isRunning { start() } else { pause() }
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
        isRunning = true
    }

    func pause() {
        timer?.invalidate()
        isRunning = false
    }

    func reset() {
        pause()
        resetTimer(for: phase)
    }

    func openSettingsApplied() {
        // Called after settings screen closes to re-apply durations if needed
        resetTimer(for: phase)
    }

    private func tick() {
        guard secondsRemaining > 0 else {
            handlePhaseCompletion()
            return
        }
        secondsRemaining -= 1
    }

    private func handlePhaseCompletion() {
        pause()
        if alertSoundEnabled {
            AudioServicesPlaySystemSound(1005) // simple system sound
        }

        switch phase {
        case .focus:
            completedFocusCount += 1
            if completedFocusCount % max(1, longBreakInterval) == 0 {
                transition(to: .longBreak)
            } else {
                transition(to: .shortBreak)
            }
        case .shortBreak, .longBreak:
            transition(to: .focus)
        }
    }

    func transition(to newPhase: Phase) {
        phase = newPhase
        resetTimer(for: newPhase)
        start()
    }

    private func resetTimer(for phase: Phase) {
        let minutes: Int
        switch phase {
        case .focus: minutes = focusMinutes
        case .shortBreak: minutes = shortBreakMinutes
        case .longBreak: minutes = longBreakMinutes
        }
        secondsRemaining = minutes * 60
    }

    var totalSecondsForPhase: Int {
        switch phase {
        case .focus: return focusMinutes * 60
        case .shortBreak: return shortBreakMinutes * 60
        case .longBreak: return longBreakMinutes * 60
        }
    }

    func formattedTime() -> String {
        let m = secondsRemaining / 60
        let s = secondsRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }
}


