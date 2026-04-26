# Someday

### The journal that keeps you pointed north.

Someday is a calm iOS companion app for staying connected to your long-term aspirations. It is not a task manager or habit tracker. It is a slow, trusted companion that keeps gently pointing at the horizon.

The home screen is a living solar system: a North Star at the centre representing your ultimate direction, with planets orbiting it (each one a long-term aspiration), and moons orbiting them, representing meaningful experiences you have logged against each aspiration.

<img width="1400" height="735" alt="hero" src="https://github.com/user-attachments/assets/381d848a-f1c0-4025-8c0f-cab44ac41408" />

---

## Features

- **Solar system home screen** - Interactive canvas with pinch-to-zoom and drag-to-pan. The whole system breathes
   with a continuous animation.
- **North Star** - A single statement of direction, not a goal with a deadline. Tap to view it full-screen with a
   monthly activity summary.                                                                                       
- **Somedays** - Coloured planets representing long-term aspirations, each with an optional note on why it       
  matters.                                                                                                         
- **Moments** - Lightweight journal entries linked to one or more Somedays, shown as moons orbiting each planet.
- **Gravitational pull** - Logging Moments against a Someday pulls it closer to the North Star. Neglected Somedays drift outward and visually fade.                                                                        
- **Daily nudge** - A single local notification at a chosen time, set to a natural transition in the day.        
- **Aging system** - Somedays inactive for 60 days begin to fade. At 90 days, the app surfaces a reminder of the aspiration.

---

## Stack

| Layer         | Technology                              |
| ------------- | --------------------------------------- |
| UI            | SwiftUI                                 |
| Persistence   | SwiftData                               |
| Animations    | TimelineView + Canvas (GPU-accelerated) |
| Haptics       | UIImpactFeedbackGenerator               |
| Notifications | UserNotifications (local, on-device)    |
| Fonts         | EB Garamond SemiBold, HarmonyOS Sans    |
| Min iOS       | iOS 17                                  |
| Backend       | None                                    |

---

## Getting Started

1. Clone the repository
2. Open `Someday.xcodeproj` in Xcode 16 or later
3. Select a simulator or physical device running iOS 17+
4. Build and run with `⌘R`

No external dependencies or package manager setup required. Everything uses native Apple frameworks.

---

## Docs

- [`Docs/DESIGN.md`](Docs/DESIGN.md) — design principles, typography, and colour palette
- [`Docs/ARCHITECTURE.md`](Docs/ARCHITECTURE.md) — project structure and module overview
- [`Docs/TODO.md`](Docs/TODO.md) — roadmap and planned features
