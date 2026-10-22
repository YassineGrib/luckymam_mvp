# Mochi Character & Animation Engine: Technical Specification & AI Blueprint

> **Notice & Attribution**: The mathematical engine, physics, state machine, and canvas implementation detailed in this guide originate from the open-source project **Coucou** by **Louis Raillé** (licensed under the MIT License). The visual persona "Mochi" and associated brand assets remain copyright (c) Louis Raillé. Use this document and code kit for personal experimentation, learning, or to implement your own distinct character design on top of this engine.

---

## 1. Executive Architecture

The character is rendered via a **procedural 60 FPS 2D canvas drawing engine**. There are:
- **No vector animation runtimes** (No Lottie, No Rive).
- **No raster assets or sprite sheets** (No PNG/GIF sequences).
- **Zero third-party animation dependencies**.

All visual elements—the squircle body, blushing cheeks, 3D spherical eyes, eyelids, pupils, particles, and floating badges—are calculated each frame using pure geometry, linear algebra, and easing curves.

```
                  ┌────────────────────────────────────────┐
                  │          Game/Tick Loop (60 FPS)       │
                  │   SwiftUI TimelineView / Flutter Ticker│
                  └───────────────────┬────────────────────┘
                                      │ deltaTime (dt)
                                      ▼
                  ┌────────────────────────────────────────┐
                  │              update(dt)                │
                  │  • Progress Tweens (Ease.out / back)   │
                  │  • Dampen Gaze towards Cursor (tanh)   │
                  │  • Handle Blinks & Idle Micro-bounces  │
                  │  • Step Particles (age, velocity, drag)│
                  │  • Mix State Colors (RGB linear lerp)  │
                  └───────────────────┬────────────────────┘
                                      │
                                      ▼
                  ┌────────────────────────────────────────┐
                  │               draw(ctx)                │
                  │  1. Radial Glow Halo                   │
                  │  2. Superellipse Body Fill + Gradients │
                  │  3. Radial Shading & Highlight Gloss   │
                  │  4. Blushing Cheeks (follow gaze)      │
                  │  5. 3D Spherical Projected Eyes        │
                  │  6. Particle System (Zzz, hearts...)   │
                  │  7. Status Badges & Overhead Hands     │
                  └────────────────────────────────────────┘
```

---

## 2. Geometry & Mathematical Foundations

### 2.1 The Body (Superellipse / Squircle)
The character's body is not a rounded rectangle; it is an organic **Lamé curve (Superellipse)** defined by:
$$\left|\frac{x}{r_x}\right|^n + \left|\frac{y}{r_y}\right|^n = 1$$
Where:
- $R = 0.3 \times \text{Canvas Side}$
- $r_x = 1.14 \times R$
- $r_y = 0.88 \times R$
- **Exponent $n = 2.7$** (creates the signature doughy squircle curvature)
- Vertical center offset: $y_{\text{center}} = y_0 + 0.06 \times R$

#### Canvas Rendering Algorithm:
To draw this on any 2D canvas (`CGContext`, `CanvasRenderingContext2D`, or Flutter `Path`):
Sample angles $\theta \in [0, 2\pi]$ (typically 48–64 samples):
$$\text{sgn}(\cos\theta) \cdot |\cos\theta|^{2/n} \cdot r_x$$
$$\text{sgn}(\sin\theta) \cdot |\sin\theta|^{2/n} \cdot r_y$$

### 2.2 Body Lighting & Volumetric Gradient
The body looks 3-dimensional through three layered fills:
1. **Base Diagonal Linear Gradient**:
   - Top-Right: `#FFFAF5` $\rightarrow$ Bottom-Left: `#DDCCBF`.
2. **Dynamic State Tint Overlay**:
   - A vertical linear gradient colored by the active state (e.g. Blue `#3B9EFF` for working, Orange `#F5A524` for approval) faded from 92% opacity at the bottom to transparent at $-0.25 \times r_y$.
3. **Radial Edge Shading (Ambient Occlusion)**:
   - Radial gradient centered at $(0, 0)$ with inner radius $0.7 \times R$ (transparent) to outer radius $1.15 \times R$ ($20\%$ black).
4. **Specular Highlight**:
   - Soft radial circle placed in the top-right corner with $55\%$ white fading to transparent.

---

## 3. 3D Spherical Eye Projection System

The defining characteristic of Mochi is how the eyes rotate across the face as if painted on a 3D sphere.

### 3.1 Gaze Physics (Cursor Tracking)
When the user's cursor moves relative to the character $(\Delta x, \Delta y)$:
1. **Nonlinear Compression**:
   $$\text{targetYaw} = \tanh\left(\frac{\Delta x}{260}\right) \times 0.62$$
   $$\text{targetPitch} = \tanh\left(\frac{\Delta y}{200}\right) \times 0.50$$
2. **Exponential Smoothing (Lag)**:
   $$\text{yaw}_{t} = \text{yaw}_{t-1} + (\text{targetYaw} - \text{yaw}_{t-1}) \times (1 - 0.0025^{dt})$$
   $$\text{pitch}_{t} = \text{pitch}_{t-1} + (\text{targetPitch} - \text{pitch}_{t-1}) \times (1 - 0.0025^{dt})$$

### 3.2 Eye Position & Roll Mechanics
- Base angular separation between eyes: $\text{spacing} = \pm 0.37 \text{ rad}$.
- Vertical pitch bias: $-0.12 \text{ rad}$.
- For each eye (left and right), compute its 3D angular coordinate $(\alpha, \beta)$ combining gaze, spacing, and full rotational roll (e.g., during celebratory spins or dizzy states).
- **Perspective Foreshortening**:
  As an eye rotates toward the silhouette of the body, its horizontal scale contracts proportionally to $\cos(\text{angle})$.
- **Horizon Clipping**:
  When an eye rolls behind the back of the head ($z < 0$), it is clipped or hidden. This allows the character to do complete somersaults and vertical eye rolls!

### 3.3 Autonomous Blinking Engine
- Random blink timer triggered every $2.2$ to $5.4$ seconds.
- **Double-Blink probability**: $22\%$ chance to immediately blink a second time 230ms later.
- Blink animation curve:
  - Close to $6\%$ height in $70\text{ ms}$ (`Ease.inOut`).
  - Open back to $100\%$ in $130\text{ ms}$ (`Ease.out`).

---

## 4. State Machine Matrix (`STATES`)

Each state alters Mochi's tint, eye shape, accessories, particle emitters, and background glow:

| State Key | Label | Hex Color | Tint Level | Eye Shape | Overhead Badge | Motion / Behavior | Audio Cue |
|---|---|---|---|---|---|---|---|
| `idle` | Rest | `#E6E9EE` | 0.0 | Pill | None | Natural idle breathing, random blinks | — |
| `working` | Working | `#3B9EFF` | 0.72 | Pill | Animated `•••` pill | Subtle focus gaze | `work.wav` |
| `thinking` | Thinking | `#8B5CF6` | 0.72 | Pill | Fixed `•••` | Gaze fixed to top-right ($+0.55, +0.55$) | `think.wav` |
| `searching`| Searching | `#6366F1` | 0.72 | Pill | Fixed `•••` | Eyes scan rhythmically left-to-right ($\sin(2.6t)$) | `search.wav` |
| `approval` | Needs Approval| `#F5A524` | 0.78 | Wide | `!` exclamation | Continuous eager bouncing ($y = -|\sin(5.2t)| \times 0.07$) | `approval.wav` |
| `question` | Question | `#22D3EE` | 0.75 | Pill | `?` question mark | Inquisitive head tilt ($+0.17\text{ rad}$) | `question.wav` |
| `error` | Error | `#F4505E` | 0.78 | Flat | Red dot | Fast horizontal shake on entry | `error.wav` |
| `finished` | Completed | `#34D399` | 0.35 | Happy arcs | Green dot | $360^\circ$ celebratory roll ($950\text{ ms}$) + golden sparks | `finish.wav` |
| `ratelimit`| Rate Limited | `#FB923C` | 0.72 | Tired | Orange dot | Sweat particles dropping | `rate.wav` |
| `sleeping` | Sleeping | `#94A3B8` | 0.32 | Closed | None | Deep breathing ($1.8t$) + floating `Zzz` particles | `sleep.wav` |
| `dizzy` | Dizzy / Slapped| `#F472B6` | 0.70 | Spirals | None | Fast double barrel roll ($1300\text{ ms}$, 2 turns) | `dizzy.wav` |

---

## 5. Emote System (`EMOTES`)

Emotes are transient overlays that temporarily take over the facial expression without breaking the underlying state:

1. **Love** (`love`):
   - Trigger: Hovering cursor over the character continuously for $1.9\text{ seconds}$.
   - Eyes: Glowing red hearts (`#FF4D6D`).
   - FX: High blush, floating heart particles, joyful micro-jump, plays `love.wav`.
2. **Surprised** (`surprised`):
   - Trigger: Starting a drag gesture.
   - Eyes: Tiny expanded dots ($1.25\times$ scale), vertical leap, plays `pop.wav`.
3. **Proud** (`proud`):
   - Trigger: Successful completion or display of results.
   - Eyes: Golden 5-point stars (`#F7B32B`), backward head tilt, plays `proud.wav`.
4. **Wink** (`wink`):
   - Trigger: Email sent or context attached.
   - Eyes: One eye closed, head tilted playfully, plays `wink.wav`.
5. **Yawn** (`yawn`):
   - Trigger: Entering idle timeout before sleep.
   - Motion: Vertical stretch, tired eyes transitioning to closed, `Z` particle, plays `yawn.wav`.
6. **Agacé / Annoyed** (`annoyed`):
   - Trigger: Single poke or click.
   - Motion: Squash & stretch, squinted slash eyes, purple glow, plays `slap.wav` + `annoyed.wav`.

---

## 6. Physics, Tweens & Easing Reference

All tweens use three foundational curves:
```swift
// Cubic Ease Out (deceleration)
func easeOut(_ t: CGFloat) -> CGFloat { 1.0 - pow(1.0 - t, 3.0) }

// Cubic Ease In-Out (smooth S-curve)
func easeInOut(_ t: CGFloat) -> CGFloat {
    t < 0.5 ? 4.0 * t * t * t : 1.0 - pow(-2.0 * t + 2.0, 3.0) / 2.0
}

// Back Ease Out (elastic overshoot / bounce)
func easeBack(_ t: CGFloat) -> CGFloat {
    let c1: CGFloat = 1.7
    let c3 = c1 + 1.0
    return 1.0 + c3 * pow(t - 1.0, 3.0) + c1 * pow(t - 1.0, 2.0)
}
```

### Squash & Stretch Formula (on Click/Slap)
```swift
// Vertical scale: compresses to 0.78, rebounds to 1.10, settles to 1.0
squashY: [[0.78, 70ms, easeOut], [1.10, 130ms, easeOut], [1.00, 170ms, easeInOut]]
// Horizontal scale: expands to 1.16, contracts to 0.95, settles to 1.0
squashX: [[1.16, 70ms, easeOut], [0.95, 130ms, easeOut], [1.00, 170ms, easeInOut]]
```

---

## 7. How to Re-implement in Flutter (`CustomPainter`)

When porting to **Flutter / Dart**, follow this architecture:

1. **Ticker Provider**: Use a `SingleTickerProviderStateMixin` with an `AnimationController` running indefinitely (`controller.repeat()`).
2. **State Container**:
   ```dart
   class BotState {
     double yaw = 0.0, pitch = 0.0, roll = 0.0, tilt = 0.0;
     double scaleX = 1.0, scaleY = 1.0;
     double eyeOpen = 1.0, blush = 0.0;
     Color currentColor = const Color(0xFFE6E9EE);
     // ...
   }
   ```
3. **CustomPainter implementation**:
   - In `paint(Canvas canvas, Size size)`:
     - Compute scale $R = 0.3 \times \text{size.shortestSide}$.
     - Translate canvas to center `(size.width / 2, size.height / 2)`.
     - Construct the Squircle `Path` using sampled angle points.
     - Paint base gradient with `Paint()..shader = LinearGradient(...).createShader(...)`.
     - Calculate projected 3D eyes and draw with `canvas.drawOval` or `canvas.drawPath`.
4. **Mouse Region**: Wrap in `MouseRegion(onHover: (e) => bot.setPointer(e.localPosition))` to feed continuous $\Delta x, \Delta y$ coordinate deltas into the tanh damper.

---

## 8. Directory Contents in this Kit

- [`swift/BotEngine.swift`](file:///C:/Users/PC%20WORLD%20DZ/.gemini/antigravity-ide/scratch/mochi_character_kit/swift/BotEngine.swift): Complete Swift 6 engine with all drawing routines and math.
- [`swift/BotCanvasView.swift`](file:///C:/Users/PC%20WORLD%20DZ/.gemini/antigravity-ide/scratch/mochi_character_kit/swift/BotCanvasView.swift): SwiftUI wrapper connecting the engine to `TimelineView`.
- [`web_prototype/index.html`](file:///C:/Users/PC%20WORLD%20DZ/.gemini/antigravity-ide/scratch/mochi_character_kit/web_prototype/index.html): Standalone HTML/JS browser sandbox. You can double-click this file to test, trigger all emotes, and inspect the raw JavaScript implementation.
- [`sounds/`](file:///C:/Users/PC%20WORLD%20DZ/.gemini/antigravity-ide/scratch/mochi_character_kit/sounds/): All 28 clean 48 kHz WAV audio assets.
