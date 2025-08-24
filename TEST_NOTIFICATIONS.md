# Notification Testing Plan

## Test Scenarios

### 1. Normal Timer Operation
- [ ] Start a Pomodoro session
- [ ] Verify notification is scheduled (check Notification Center)
- [ ] Let timer complete
- [ ] Verify notification appears

### 2. Pause Timer
- [ ] Start a Pomodoro session
- [ ] Pause the timer
- [ ] Verify notification is cancelled (check Notification Center)
- [ ] Resume timer
- [ ] Verify notification is rescheduled

### 3. Reset Timer
- [ ] Start a Pomodoro session
- [ ] Reset the timer
- [ ] Verify notification is cancelled

### 4. App Termination
- [ ] Start a Pomodoro session
- [ ] Quit the app (Cmd+Q or menu)
- [ ] Verify notification is cancelled
- [ ] Check that no notification appears after the timer would have completed

### 5. Window Closing (macOS)
- [ ] Start a Pomodoro session
- [ ] Close the main window (app remains in menu bar)
- [ ] Verify timer continues and notification remains scheduled
- [ ] Verify notification appears when timer completes

### 6. Background/Foreground (if applicable)
- [ ] Start a Pomodoro session
- [ ] Hide the app
- [ ] Verify notification remains scheduled
- [ ] Unhide the app
- [ ] Verify timer state is correct

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
  
- Notifications should remain scheduled when:
  - Window is closed but app remains in menu bar
  - App is hidden/unhidden
  - App goes to background (continues running)