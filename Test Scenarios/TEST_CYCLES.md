# Cycle Testing Plan

## Test Scenarios for Cycle Management

### TC-CYC-001: Normal Cycle Progression
- [ ] Complete 1st Pomodoro → Should offer Short Break (Cycle 1)
- [ ] Complete 2nd Pomodoro → Should offer Short Break (Cycle 1)
- [ ] Complete 3rd Pomodoro → Should offer Short Break (Cycle 1)
- [ ] Complete 4th Pomodoro → Should offer Long Break (Cycle 1)
- [ ] After Long Break → Should start Cycle 2
- [ ] Complete 5th Pomodoro → Should offer Short Break (Cycle 2)

### TC-CYC-002: Direct Long Break Selection
- [ ] Start the app fresh (Cycle 1)
- [ ] Select "Start Long Break" from menu
- [ ] Verify cycle counter REMAINS at 1 (doesn't increment yet)
- [ ] Complete or skip the long break
- [ ] Verify cycle counter increments to 2 AFTER long break ends
- [ ] Next Pomodoro should be in Cycle 2

### TC-CYC-003: Daily Reset
- [ ] Complete several cycles on Day 1
- [ ] Close and reopen app on Day 2
- [ ] Verify cycle resets to 1
- [ ] First Pomodoro of Day 2 → Should offer Short Break
- [ ] 4th Pomodoro of Day 2 → Should offer Long Break

### TC-CYC-004: Mid-Day App Restart
- [ ] Complete 2 Pomodoros (in Cycle 1)
- [ ] Close and restart the app
- [ ] Verify still in Cycle 1
- [ ] Complete 3rd Pomodoro → Should offer Short Break
- [ ] Complete 4th Pomodoro → Should offer Long Break

### TC-CYC-005: Manual Break Selection Logic
- [ ] Complete 3 Pomodoros (still in Cycle 1)
- [ ] Manually select "Start Long Break"
- [ ] Verify cycle REMAINS at 1 during long break
- [ ] Complete the long break
- [ ] Verify cycle increments to 2 after long break completion
- [ ] Next session should be Pomodoro in Cycle 2

### TC-CYC-006: First Pomodoro of the Day (Range Crash Bug)
- [ ] Start app fresh (no pomodoros completed today)
- [ ] Complete first Pomodoro
- [ ] Click "Next Session" button
- [ ] Verify app doesn't crash (was crashing with range 1...0)
- [ ] Verify display shows "1×" for completed pomodoro
- [ ] Verify Short Break is offered (not Long Break)

## Expected Behavior

### Cycle Counter Rules:
1. **Start of day**: Always begins at Cycle 1
2. **Cycle completion**: A cycle is considered complete when:
   - Long Break session ENDS (not when it starts)
   - This happens after transitioning FROM long break TO pomodoro
3. **During Long Break**: Cycle counter remains unchanged
4. **After Long Break ends**: New cycle begins (counter increments)
5. **App restart (same day)**: Cycle = Number of completed Long Breaks today + 1
6. **App restart (new day)**: Resets to Cycle 1

### Cycle Calculation Formula:
```
Current Cycle = Today's Completed Long Breaks + 1
```

### Important Note:
The cycle counter increments when a Long Break ENDS, not when it starts. This means:
- Starting a long break does NOT increment the cycle
- Completing/finishing a long break increments the cycle
- The new cycle begins when transitioning FROM long break TO pomodoro

### Visual Indicator:
The timer should display cycles as filled/empty circles:
- 🍅 = Completed Pomodoro in current cycle
- ○ = Remaining Pomodoro in current cycle
- Example after 2 Pomodoros: 🍅🍅○○

## How to Verify

1. **Check cycle counter**: Look at the displayed cycle number
2. **Check break type offered**: After completing a Pomodoro
3. **Check statistics**: Verify today's Pomodoro count matches cycle
4. **Console logging**: Add debug logs if needed to track cycle changes