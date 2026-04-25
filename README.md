# ☀️ Someday

## The journal that keeps you pointed north.

<img width="1400" height="735" alt="hero" src="https://github.com/user-attachments/assets/381d848a-f1c0-4025-8c0f-cab44ac41408" />

Someday is a calm iOS companion app for staying connected to your long-term aspirations. It is not a task manager or habit tracker. It is a slow, trusted companion that keeps gently pointing at the horizon.

The home screen is a living solar system: a North Star at the centre representing your ultimate direction, with planets orbiting it (each one a long-term aspiration), and moons orbiting them, representing meaningful experiences you have logged against each aspiration.

---

## Features

- **Solar system home screen** - interactive canvas with pinch-to-zoom and drag-to-pan; the whole system breathes with a continuous animation
- **North Star** - one statement of direction, not a goal with a deadline; tapping reveals it full-screen with a monthly activity summary
- **Somedays** - coloured planets, each representing a long-term aspiration with an optional "why it matters" note
- **Moments** - lightweight journal entries linked to one or more Somedays, shown as moons orbiting each planet
- **Gravitational pull** - more Moments logged against a Someday pulls it closer to the North Star; neglected ones drift outward and visually fade
- **Daily nudge** - a single local notification at a time the user chooses, timed to a natural transition in their day
- **Aging system** - Somedays inactive for 60 days begin to fade; at 90 days the app reminds the user of this aspiration

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
