# Cycle Testing Plan

## Test Scenarios for Cycle Management

### 1. Normal Cycle Progression
- [ ] Complete 1st Pomodoro → Should offer Short Break (Cycle 1)
- [ ] Complete 2nd Pomodoro → Should offer Short Break (Cycle 1)
- [ ] Complete 3rd Pomodoro → Should offer Short Break (Cycle 1)
- [ ] Complete 4th Pomodoro → Should offer Long Break (Cycle 1)
- [ ] After Long Break → Should start Cycle 2
- [ ] Complete 5th Pomodoro → Should offer Short Break (Cycle 2)

### 2. Direct Long Break Selection
- [ ] Start the app fresh (Cycle 1)
- [ ] Select "Start Long Break" from menu
- [ ] Verify cycle counter updates appropriately
- [ ] Next Pomodoro should be in the correct cycle

### 3. Daily Reset
- [ ] Complete several cycles on Day 1
- [ ] Close and reopen app on Day 2
- [ ] Verify cycle resets to 1
- [ ] First Pomodoro of Day 2 → Should offer Short Break
- [ ] 4th Pomodoro of Day 2 → Should offer Long Break

### 4. Mid-Day App Restart
- [ ] Complete 2 Pomodoros (in Cycle 1)
- [ ] Close and restart the app
- [ ] Verify still in Cycle 1
- [ ] Complete 3rd Pomodoro → Should offer Short Break
- [ ] Complete 4th Pomodoro → Should offer Long Break

### 5. Manual Break Selection Logic
- [ ] Complete 3 Pomodoros
- [ ] Manually select "Start Long Break"
- [ ] Verify cycle updates correctly
- [ ] After break, should continue appropriately

## Expected Behavior

### Cycle Counter Rules:
1. **Start of day**: Always begins at Cycle 1
2. **After 4 Pomodoros**: Automatically suggests Long Break and moves to next cycle
3. **Manual Long Break**: Updates cycle based on today's completed Pomodoros
4. **App restart (same day)**: Preserves cycle position based on today's Pomodoros
5. **App restart (new day)**: Resets to Cycle 1

### Cycle Calculation Formula:
```
Current Cycle = (Today's Completed Pomodoros / 4) + 1
```

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