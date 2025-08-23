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
    
    // MARK: - Properties
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let timeLabel = NSTextField()
    private weak var store: Store?
    
    // Cached calculations
    private lazy var center = CGPoint(x: Constants.menuProgressSize / 2, y: Constants.menuProgressSize / 2)
    private lazy var radius = (Constants.menuProgressSize - Constants.strokeInset) / 2
    
    init(store: Store) {
        self.store = store
        super.init(frame: NSRect(x: 0, y: 0, width: Constants.menuTimerViewWidth, height: Constants.menuTimerViewHeight))
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
        // Calculate total width needed for progress + spacing + text
        let totalContentWidth = Constants.menuProgressSize + Constants.menuTimeLabelSpacing + Constants.menuContentApproximateWidth
        let startX = (Constants.menuTimerViewWidth - totalContentWidth) / 2
        
        let container = NSView(frame: NSRect(
            x: startX,
            y: (frame.height - Constants.menuProgressSize) / 2,
            width: Constants.menuProgressSize,
            height: Constants.menuProgressSize
        ))
        container.wantsLayer = true
        return container
    }
    
    private func setupBackgroundLayer(in container: NSView) {
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: Constants.menuProgressSize, height: Constants.menuProgressSize)
        backgroundLayer.path = createCirclePath(center: center, radius: radius)
        backgroundLayer.fillColor = NSColor(Colors.progressFillBackground).cgColor
        // Will be set dynamically in updateDisplay based on current session
        backgroundLayer.lineWidth = Constants.menuProgressLineWidth
        container.layer?.addSublayer(backgroundLayer)
    }
    
    private func setupProgressLayer(in container: NSView) {
        progressLayer.frame = backgroundLayer.frame
        progressLayer.fillColor = NSColor(Colors.progressFillBackground).cgColor
        progressLayer.lineWidth = Constants.menuProgressLineWidth
        progressLayer.lineCap = .round
        container.layer?.addSublayer(progressLayer)
    }
    
    private func setupTimeLabel() {
        // Calculate centered position
        let totalContentWidth = Constants.menuProgressSize + Constants.menuTimeLabelSpacing + 80
        let startX = (Constants.menuTimerViewWidth - totalContentWidth) / 2
        
        timeLabel.isBezeled = false
        timeLabel.isEditable = false
        timeLabel.drawsBackground = false
        timeLabel.alignment = .left
        timeLabel.font = Fonts.menuTimerFont()
        timeLabel.textColor = NSColor(Colors.primaryText)
        timeLabel.frame = NSRect(
            x: startX + Constants.menuProgressSize + Constants.menuTimeLabelSpacing,
            y: (frame.height - Constants.menuTimeLabelHeight) / 2,
            width: Constants.menuTimeLabelWidth,
            height: Constants.menuTimeLabelHeight
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
            configureTimeLabelForActiveState(store.formattedTime, store: store)
        }
    }
    
    private func configureTimeLabelForIdleState() {
        timeLabel.stringValue = "Ready"
        timeLabel.font = Fonts.menuReadyFont()
        timeLabel.textColor = NSColor(Colors.secondaryText)
    }
    
    private func configureTimeLabelForActiveState(_ time: String, store: Store) {
        timeLabel.stringValue = time
        timeLabel.font = Fonts.menuTimerFont()
        
        // Use session color for text
        if store.timerState == .completed {
            timeLabel.textColor = NSColor(Colors.completed)
        } else {
            timeLabel.textColor = NSColor(store.currentSession.color)
        }
    }
    
    private func updateProgressIndicator(for store: Store) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Update background circle color to match current session
        if store.timerState == .idle {
            // Use a subtle gray for idle state
            backgroundLayer.strokeColor = NSColor.tertiaryLabelColor.withAlphaComponent(0.2).cgColor
            progressLayer.path = nil
        } else {
            // Use session color for active states
            backgroundLayer.strokeColor = NSColor(store.currentSession.progressBackgroundColor).cgColor
            
            // Update progress circle color
            progressLayer.strokeColor = progressColor(for: store).cgColor
            
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
