# Notification Testing Plan

## Test Scenarios

### TC-NOTIF-001: Normal Timer Operation
- [ ] Start a Pomodoro session
- [ ] Verify notification is scheduled (check Notification Center)
- [ ] Let timer complete
- [ ] Verify notification appears

### TC-NOTIF-002: Pause Timer ✅
- [ ] Start a Pomodoro session
- [ ] Pause the timer
- [ ] Verify notification is cancelled (check Notification Center)
- [ ] Resume timer
- [ ] Verify notification is rescheduled

### TC-NOTIF-003: Reset Timer ✅
- [ ] Start a Pomodoro session
- [ ] Reset the timer
- [ ] Verify notification is cancelled

### TC-NOTIF-004: App Termination ✅
- [ ] Start a Pomodoro session
- [ ] Quit the app (Cmd+Q or menu)
- [ ] Verify notification is cancelled
- [ ] Check that no notification appears after the timer would have completed

### TC-NOTIF-005: Session Switching ✅
- [ ] Start a Pomodoro session
- [ ] Switch to Short Break (from menu)
- [ ] Verify previous notification is cancelled
- [ ] Verify new notification is scheduled for Short Break
- [ ] Start a Pomodoro session
- [ ] Skip to break
- [ ] Verify previous notification is cancelled

### TC-NOTIF-006: Window Closing (macOS)
- [ ] Start a Pomodoro session
- [ ] Close the main window (app remains in menu bar)
- [ ] Verify timer continues and notification remains scheduled
- [ ] Verify notification appears when timer completes

### TC-NOTIF-007: Background/Foreground (if applicable)
- [ ] Start a Pomodoro session
- [ ] Hide the app
- [ ] Verify notification remains scheduled
- [ ] Unhide the app
- [ ] Verify timer state is correct

### TC-NOTIF-008: Break Type Switching
- [ ] Start a Short Break
- [ ] During the break, select "Start Long Break" from menu
- [ ] Verify previous Short Break notification is cancelled
- [ ] Verify new Long Break notification is scheduled
- [ ] Let Long Break complete
- [ ] Verify correct notification appears

### TC-NOTIF-009: Pomodoro to Break Direct Switch
- [ ] Start a Pomodoro session
- [ ] During the Pomodoro, select "Start Long Break" from menu
- [ ] Verify Pomodoro notification is cancelled
- [ ] Verify Long Break notification is scheduled
- [ ] Verify Pomodoro is NOT counted as completed

## How to Check Scheduled Notifications (macOS)

1. Open Terminal
2. Run: `pmset -g assertions` to see if timer is keeping system awake
3. Check System Preferences > Notifications to ensure app has permission
4. Use Console app to filter for your app's notifications

## Expected Behavior

- Notifications should ONLY be cancelled when:
  - Timer is paused
  - Timer is reset
  - App is terminated (Quit)
  - Session is switched (Skip to Break, Skip to Pomodoro)
  - Break is started directly from menu (Start Short/Long Break)
  
- Notifications should remain scheduled when:
  - Window is closed but app remains in menu bar
  - App is hidden/unhidden
  - App goes to background (continues running)