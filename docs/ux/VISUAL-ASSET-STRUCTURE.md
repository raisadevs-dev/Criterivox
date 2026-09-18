# Visual Asset Structure

This directory tree is intentionally prepared for the Criterivox PNG/SVG workflow.

Add supplied artwork into the matching character/world/UI folders. Keep filenames lowercase_snake_case and preserve canonical character identity.

For each character, the expected semantic files are:
- `<character>_portrait.png`
- `<character>_front.png`, `<character>_side.png`, `<character>_back.png`
- `<character>_neutral.png`, `<character>_smiling.png`, `<character>_thinking.png`, `<character>_focused.png`, `<character>_surprised.png`
- `<character>_idle.png`, `<character>_receive.png`, `<character>_work.png`, `<character>_communicate.png`, `<character>_handoff.png`, `<character>_complete.png`

Accessories and tools use descriptive filenames, for example `<character>_pendant.svg`.

The empty folders are retained by `.gitkeep` files because Git does not track empty directories.
