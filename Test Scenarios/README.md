# Test Scenarios for Pomodoro Timer

This folder contains comprehensive test scenarios for different aspects of the Pomodoro Timer application.

## Test Documents

### 1. [Notifications Testing](TEST_NOTIFICATIONS.md)
Tests for notification system behavior including:
- Timer completion notifications (TC-NOTIF-001 to TC-NOTIF-007)
- Notification cancellation on pause/reset
- App termination handling
- Session switching behavior

### 2. [Cycle Management Testing](TEST_CYCLES.md)
Tests for cycle counting logic including:
- Normal cycle progression (TC-CYC-001 to TC-CYC-006)
- Manual long break selection
- Daily reset behavior
- Cycle calculation rules

### 3. [Display Testing](TEST_DISPLAY.md)
Tests for statistics display including:
- Cycle counter display (TC-DISP-001 to TC-DISP-008)
- Pomodoro count formatting
- Visual indicators
- Edge cases and day boundaries

## Test Case ID Format
- **TC-NOTIF-XXX**: Notification test cases
- **TC-CYC-XXX**: Cycle management test cases
- **TC-DISP-XXX**: Display test cases

## General Testing Guidelines

### Before Testing
1. Build the app in Debug mode
2. Clear any previous app data if testing fresh scenarios
3. Ensure notifications are enabled in System Preferences

### During Testing
1. Follow test scenarios step by step
2. Document any deviations from expected behavior
3. Note the exact steps to reproduce any issues

### After Testing
1. Create issues for any bugs found
2. Update test scenarios if behavior has changed
3. Mark completed tests with ✅

## Key Behaviors to Verify

### Cycle Logic
- **Cycle completes when**: Long break starts (automatic or manual)
- **Current cycle formula**: `Today's Long Breaks + 1`
- **Daily reset**: Cycles reset to 1 at start of new day

### Notifications
- **Cancelled when**: Pause, Reset, Quit, Session switch
- **Scheduled when**: Start, Resume
- **Persist when**: Window closed (app in menu bar)

### Display Format
- **Pomodoros**: `n×` format (e.g., `4× 2×`)
- **Cycles**: Based on long breaks taken
- **Daily stats**: Reset at midnight

## Test Coverage Matrix

| Feature | Notifications | Cycles | Display |
|---------|--------------|--------|---------|
| Start Timer | ✓ | ✓ | ✓ |
| Pause/Resume | ✓ | - | ✓ |
| Reset | ✓ | ✓ | ✓ |
| Complete Pomodoro | ✓ | ✓ | ✓ |
| Skip to Break | ✓ | ✓ | ✓ |
| Manual Long Break | ✓ | ✓ | ✓ |
| App Restart | ✓ | ✓ | ✓ |
| New Day | ✓ | ✓ | ✓ |

## Known Issues & Edge Cases

1. **Manual Long Break**: Completes cycle regardless of pomodoro count
2. **Day Boundary**: Statistics reset but notifications might persist
3. **Background Mode**: Timer continues but display may not update
4. **Range Crash (Fixed)**: App was crashing when completing first pomodoro of the day due to invalid range 1...0 when longBreaks = 0

## How to Report Issues

When reporting issues, please include:
1. Test scenario being executed
2. Expected behavior
3. Actual behavior
4. Steps to reproduce
5. App version and OS version
6. Screenshots if applicable