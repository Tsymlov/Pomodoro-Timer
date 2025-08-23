//
//  MenuTimerView.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 17.08.2025.
//

#if os(macOS)
import AppKit
import SwiftUI

// Custom NSView for timer display in menu
final class MenuTimerView: NSView {
    // MARK: - Constants
    private enum Constants {
        static let progressSize: CGFloat = 24
        static let padding: CGFloat = 16
        static let lineWidth: CGFloat = 3
        static let strokeInset: CGFloat = 3
        static let timeLabelSpacing: CGFloat = 12
        static let timeLabelHeight: CGFloat = 28
        static let viewWidth: CGFloat = 200
        static let viewHeight: CGFloat = 44
        static let backgroundAlpha: CGFloat = 0.2
        static let readyFontSize: CGFloat = 20
        static let timeFontSize: CGFloat = 24
    }
    
    // MARK: - Properties
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let timeLabel = NSTextField()
    private weak var store: Store?
    
    // Cached calculations
    private lazy var center = CGPoint(x: Constants.progressSize / 2, y: Constants.progressSize / 2)
    private lazy var radius = (Constants.progressSize - Constants.strokeInset) / 2
    
    init(store: Store) {
        self.store = store
        super.init(frame: NSRect(x: 0, y: 0, width: Constants.viewWidth, height: Constants.viewHeight))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        wantsLayer = true
        
        let progressContainer = createProgressContainer()
        setupBackgroundLayer(in: progressContainer)
        setupProgressLayer(in: progressContainer)
        addSubview(progressContainer)
        
        setupTimeLabel()
        addSubview(timeLabel)
        
        updateDisplay()
    }
    
    private func createProgressContainer() -> NSView {
        let container = NSView(frame: NSRect(
            x: Constants.padding,
            y: (frame.height - Constants.progressSize) / 2,
            width: Constants.progressSize,
            height: Constants.progressSize
        ))
        container.wantsLayer = true
        return container
    }
    
    private func setupBackgroundLayer(in container: NSView) {
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: Constants.progressSize, height: Constants.progressSize)
        backgroundLayer.path = createCirclePath(center: center, radius: radius)
        backgroundLayer.fillColor = NSColor.clear.cgColor
        backgroundLayer.strokeColor = NSColor(Colors.progressBackground).withAlphaComponent(Constants.backgroundAlpha).cgColor
        backgroundLayer.lineWidth = Constants.lineWidth
        container.layer?.addSublayer(backgroundLayer)
    }
    
    private func setupProgressLayer(in container: NSView) {
        progressLayer.frame = backgroundLayer.frame
        progressLayer.fillColor = NSColor.clear.cgColor
        progressLayer.lineWidth = Constants.lineWidth
        progressLayer.lineCap = .round
        container.layer?.addSublayer(progressLayer)
    }
    
    private func setupTimeLabel() {
        timeLabel.isBezeled = false
        timeLabel.isEditable = false
        timeLabel.drawsBackground = false
        timeLabel.alignment = .left
        timeLabel.font = NSFont.monospacedDigitSystemFont(ofSize: Constants.timeFontSize, weight: .medium)
        timeLabel.textColor = NSColor(Colors.primaryText)
        timeLabel.frame = NSRect(
            x: Constants.padding + Constants.progressSize + Constants.timeLabelSpacing,
            y: (frame.height - Constants.timeLabelHeight) / 2,
            width: 120,
            height: Constants.timeLabelHeight
        )
    }
    
    private func createCirclePath(center: CGPoint, radius: CGFloat) -> CGPath {
        return CGPath(ellipseIn: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ), transform: nil)
    }
    
    private func createProgressPath(center: CGPoint, radius: CGFloat, progress: CGFloat) -> CGPath {
        let path = CGMutablePath()
        // In macOS, the coordinate system has origin at bottom-left
        // Angles: 0° is at 3 o'clock, 90° is at 12 o'clock (top)
        // We want to start at 12 o'clock and go clockwise
        let startAngle = CGFloat.pi / 2  // Start from top (12 o'clock) 
        let endAngle = startAngle - (2 * CGFloat.pi * progress)  // Subtract to go clockwise
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true  // true for counterclockwise in the flipped coordinate system (appears clockwise visually)
        )
        
        return path
    }
    
    func updateDisplay() {
        guard let store = store else { return }
        
        updateTimeLabel(for: store)
        updateProgressIndicator(for: store)
        forceRedraw()
    }
    
    private func updateTimeLabel(for store: Store) {
        if store.timerState == .idle {
            configureTimeLabelForIdleState()
        } else {
            configureTimeLabelForActiveState(store.formattedTime)
        }
    }
    
    private func configureTimeLabelForIdleState() {
        timeLabel.stringValue = "Ready"
        timeLabel.font = NSFont.systemFont(ofSize: Constants.readyFontSize, weight: .medium)
    }
    
    private func configureTimeLabelForActiveState(_ time: String) {
        timeLabel.stringValue = time
        timeLabel.font = NSFont.monospacedDigitSystemFont(ofSize: Constants.timeFontSize, weight: .medium)
    }
    
    private func updateProgressIndicator(for store: Store) {
        progressLayer.strokeColor = progressColor(for: store).cgColor
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if store.timerState == .idle {
            progressLayer.path = nil
        } else {
            let progress = CGFloat(store.progress)
            progressLayer.path = createProgressPath(center: center, radius: radius, progress: progress)
        }
        
        CATransaction.commit()
    }
    
    private func forceRedraw() {
        needsDisplay = true
    }
    
    private func progressColor(for store: Store) -> NSColor {
        if store.timerState == .completed {
            return NSColor(Colors.completed)
        }
        
        // Use existing color from SessionType extension
        return NSColor(store.currentSession.color)
    }
}


#endif
