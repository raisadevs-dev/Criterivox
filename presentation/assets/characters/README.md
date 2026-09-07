# Character Vector Assets

This directory contains character artwork authored as vector assets for Flutter.

## Animation pipeline

```text
Character design
      ↓
Glaxnimate
      ↓
SVG artwork / animation source
      ↓
Flutter SVG renderer + Flutter motion
      ↓
Visible character
```

Dharen and Syvax use SVG artwork while semantic character state remains owned by the Python/application runtime. Flutter maps those states to presentation motion, visibility, emphasis, and reduced-motion behavior.

Shared character states remain:

`IDLE`, `RECEIVE`, `WORK`, `COMMUNICATE`, `HANDOFF`, `COMPLETE`, `WARNING`.
