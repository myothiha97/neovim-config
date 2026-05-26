
# Blink Cmp: ENTER Key Accept Bug

## Status
Currently not happening, but needs continued monitoring to confirm it is completely fixed.

## Issue
Intermittently, using the ENTER key to accept completion suggestions stops working mid-session. Instead of accepting the suggestion, pressing ENTER either inserts a newline or moves to the next line.

The issue has persisted for a long time and is not yet completely resolved.

## Notes
- Occurs randomly in the middle of coding sessions
- Not consistently reproducible
- May be related to state drift in blink-cmp or a keybinding conflict that activates conditionally
