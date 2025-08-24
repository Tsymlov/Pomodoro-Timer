# Display Testing Scenarios

## Cycle Display Format
The display shows completed pomodoros as: `n×` where n is the number of pomodoros

## Test Scenarios

### Scenario 1: Fresh Start
- **State**: No pomodoros completed today
- **Expected Display**: Nothing (empty string)
- **Cycle Counter**: 1

### Scenario 2: First Pomodoros
- **State**: 2 pomodoros completed, no long breaks
- **Expected Display**: `2×`
- **Cycle Counter**: 1

### Scenario 3: Full First Cycle
- **State**: 4 pomodoros completed, no long breaks yet
- **Expected Display**: `4×`
- **Cycle Counter**: 1
- **Note**: Should offer Long Break

### Scenario 4: After First Long Break
- **State**: 4 pomodoros, 1 long break completed
- **Expected Display**: `4×`
- **Cycle Counter**: 2
- **Note**: First cycle complete, now in cycle 2

### Scenario 5: Mid Second Cycle
- **State**: 6 pomodoros, 1 long break
- **Expected Display**: `4× 2×`
- **Cycle Counter**: 2
- **Note**: Shows 4 from cycle 1, 2 from current cycle 2

### Scenario 6: Manual Long Break Early
- **State**: 2 pomodoros, then manual Long Break
- **Expected Display**: `2×`
- **Cycle Counter**: 2
- **Note**: Even with only 2 pomodoros, manual Long Break completes the cycle

### Scenario 7: Multiple Cycles
- **State**: 9 pomodoros, 2 long breaks
- **Expected Display**: `4× 4× 1×`
- **Cycle Counter**: 3
- **Note**: Two complete cycles of 4, plus 1 in current cycle

### Scenario 8: Uneven Cycles (Manual Breaks)
- **State**: User did: 2 pomodoros → Long Break → 3 pomodoros → Long Break → 1 pomodoro
- **Total**: 6 pomodoros, 2 long breaks
- **Expected Display**: `2× 3× 1×`
- **Cycle Counter**: 3

## Visual Indicators

The display should show:
1. **Completed cycles** - based on Long Breaks taken
2. **Current cycle progress** - pomodoros since last Long Break
3. **Cycle number** - increments with each Long Break

## How to Verify

1. Complete pomodoros and check the display updates
2. Take Long Breaks (auto or manual) and verify cycle increments
3. Restart app and verify display reconstructs correctly
4. Check that display matches: `[cycle1]× [cycle2]× ... [current]×`

## Edge Cases to Test

1. **Zero pomodoros** - Should show nothing
2. **Only breaks** - Starting with breaks shouldn't affect display
3. **Skip patterns** - Using Skip to Break/Pomodoro
4. **Day boundary** - Display should reset for new day
5. **App restart** - Should reconstruct from today's statistics