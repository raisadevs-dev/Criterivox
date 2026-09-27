# Syvax and Bloom First-Class Migration

## Syvax

Syvax owns the interaction/gateway boundary:

- request preflight and safety classification
- intent extraction
- route construction
- oversight mode
- human-facing output translation
- routing/task traces
- adaptive planner integration

Shared planners and home services remain shared. Syvax is the gateway that invokes them.

Dart ownership lives under `presentation/lib/Syvax/`; global identity, visual and navigation registries remain shared.

## Bloom

Bloom is **not one of the 15 Home workers**. It is the civilization gateway/companion that follows the human through Criterivox.

Bloom owns:

- capability selection
- capability-to-application-action mapping
- capability activation
- home activation/seeding
- budgets
- mode state
- checkpoints
- capability traces
- civilization-level companion presentation

The underlying Home workers remain owners of their actual computational responsibilities.

Bloom therefore does not absorb Sandre, Dharen, Syvax, Vivren, Pramon, etc. It routes to them.

## Four-layer treatment

Both received:
1. first-class Python ownership
2. focused Python tests
3. first-class Dart presentation ownership
4. focused Dart tests/documentation

Legacy imports remain as compatibility facades.

## Boundary

Bloom is a gateway/companion. Syvax is the interaction/gateway worker. They are related but not merged:

Bloom = civilization-level capability doorway.

Syvax = task-level human/system interaction and routing.
