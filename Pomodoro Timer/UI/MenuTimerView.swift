//
//  MenuTimerView.swift
//  Pomodoro Timer
//
//  Created by Alexey Tsymlov on 23.08.2025.
//

#if os(macOS)
import AppKit
import SwiftUI

final class MenuTimerView: NSView {
    // MARK: - Properties
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private let timeLabel = NSTextField()
    private weak var store: Store?

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
        let totalContentWidth = Constants.menuProgressSize + Constants.menuTimeLabelSpacing + Constants.menuContentApproximateWidth
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
        let startAngle = CGFloat.pi / 2
        let endAngle = startAngle - (2 * CGFloat.pi * progress)

        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
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
        timeLabel.textColor = textColor(for: store)
    }

    private func textColor(for store: Store) -> NSColor {
        store.timerState == .completed ? NSColor(Colors.completed) : NSColor(store.currentSession.color)
    }

    private func updateProgressIndicator(for store: Store) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        if store.timerState == .idle {
            configureIdleProgressIndicator()
        } else {
            configureActiveProgressIndicator(for: store)
        }

        CATransaction.commit()
    }

    private func configureIdleProgressIndicator() {
        backgroundLayer.strokeColor = NSColor.tertiaryLabelColor.withAlphaComponent(Constants.menuBarBackgroundAlpha).cgColor
        progressLayer.path = nil
    }

    private func configureActiveProgressIndicator(for store: Store) {
        backgroundLayer.strokeColor = NSColor(store.currentSession.progressBackgroundColor).cgColor
        progressLayer.strokeColor = progressColor(for: store).cgColor

        let progress = CGFloat(store.progress)
        progressLayer.path = createProgressPath(center: center, radius: radius, progress: progress)
    }

    private func forceRedraw() {
        needsDisplay = true
    }

    private func progressColor(for store: Store) -> NSColor {
        store.timerState == .completed ? NSColor(Colors.completed) : NSColor(store.currentSession.color)
    }
}

#endif
