# Character Skeletal Runtime Assets

Character visuals are rendered by the local Web skeletal runtime, not by Flutter SVG assets.

## Animation pipeline

```text
Character reference / design
      ↓
2D bone + slot authoring data
      ↓
plain JSON skeleton + animation tracks
      ↓
local HTML + standard JavaScript runtime
      ↓
Flutter Web HtmlElementView boundary
      ↓
visible semantic character
```

The runtime follows a DragonBones / Spine-style skeletal model: bones, slots, character-specific skins/signatures, animation tracks and blended state transitions. The current renderer is an original Criterivox runtime and does not require a network asset service.

Python remains authoritative for semantic character state. Flutter transports and exposes that state; JavaScript owns skeletal interpolation and rendering.

Shared character states remain:

`IDLE`, `RECEIVE`, `WORK`, `COMMUNICATE`, `HANDOFF`, `COMPLETE`, `WARNING`.
