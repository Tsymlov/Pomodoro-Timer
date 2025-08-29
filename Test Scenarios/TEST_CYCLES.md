# Cycle Testing Plan

## Test Scenarios for Cycle Management

### TC-CYC-001: Normal Cycle Progression
- [ ] Complete 1st Pomodoro → Should auto-suggest Short Break (Cycle 1)
- [ ] Complete 2nd Pomodoro → Should auto-suggest Short Break (Cycle 1)
- [ ] Complete 3rd Pomodoro → Should auto-suggest Short Break (Cycle 1)
- [ ] Complete 4th Pomodoro → Should auto-suggest Long Break (Cycle 1)
- [ ] After Long Break → Should start Cycle 2
- [ ] Complete 5th Pomodoro → Should auto-suggest Short Break (Cycle 2)
- [ ] Note: Manual break selection available at any time via menu

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

### TC-CYC-006: First Pomodoro of the Day (Range Crash Bug - Fixed)
- [ ] Start app fresh (no pomodoros completed today)
- [ ] Complete first Pomodoro
- [ ] Click "Next Session" button
- [ ] Verify app doesn't crash (was crashing with range 1...0)
- [ ] Verify display shows "1×" for completed pomodoro
- [ ] Verify Short Break is auto-suggested (not Long Break)

### TC-CYC-007: Manual Break Selection During Pomodoro
- [ ] Start a Pomodoro session
- [ ] During the Pomodoro, open menu
- [ ] Verify "Start Short Break" and "Start Long Break" options are available
- [ ] Select "Start Long Break"
- [ ] Verify Pomodoro is recorded as incomplete
- [ ] Verify Long Break starts immediately
- [ ] Verify cycle remains unchanged until break completes

### TC-CYC-008: Switching Between Break Types
- [ ] Start a Short Break
- [ ] During the Short Break, open menu
- [ ] Verify both break options are available
- [ ] Select "Start Long Break"
- [ ] Verify Long Break starts immediately
- [ ] Complete the Long Break
- [ ] Verify cycle increments after Long Break completion

### TC-CYC-009: Break Options in Completed State
- [ ] Complete a Pomodoro naturally (let timer finish)
- [ ] In completed state, open menu
- [ ] Verify "Start Short Break" and "Start Long Break" are available
- [ ] Select preferred break type
- [ ] Verify selected break starts

### TC-CYC-010: Break Options NOT Available During Pause
- [ ] Start any session (Pomodoro or Break)
- [ ] Pause the session
- [ ] Open menu
- [ ] Verify "Start Short Break" and "Start Long Break" are NOT shown
- [ ] Resume session
- [ ] Verify break options become available again

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

### Break Selection Rules:
1. **Automatic selection**: After completing Pomodoro, system auto-suggests:
   - Short Break for Pomodoros 1-3 in a cycle
   - Long Break for 4th Pomodoro (multiple of 4)
2. **Manual selection**: Available via menu at any time EXCEPT during pause:
   - Can override automatic suggestion
   - Can switch between break types mid-session
   - Can start break from Pomodoro (marks it incomplete)
3. **Menu availability**:
   - "Start Short/Long Break" shown in: idle, running, completed states
   - NOT shown when: paused

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