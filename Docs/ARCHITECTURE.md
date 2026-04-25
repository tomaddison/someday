# Architecture

The project is organised by feature. Shell-level wiring lives in `App/`, side-effect singletons in `Services/`, reusable views in `Components/`, and cross-cutting helpers in `Extensions/`.

```
Someday/
├── App/                       # App shell
│   ├── SomedayApp.swift       # Entry point, ModelContainer
│   ├── RootView.swift         # Splash / onboarding / main gate
│   ├── AppAppearance.swift    # UINavigationBar appearance setup
│   └── Constants.swift        # App-wide constants (aging thresholds, sizing, layout)
│
├── Models/                    # SwiftData models
│   ├── User.swift
│   ├── SomedayItem.swift      # Aging logic, gradient generation
│   └── Moment.swift
│
├── Services/                  # Side-effect singletons
│   ├── HapticManager.swift
│   └── NotificationManager.swift
│
├── Components/                # Reusable SwiftUI views
│   └── StarFieldView.swift
│
├── Extensions/
│   ├── Color+Someday.swift    # Named colour palette
│   ├── Font+Someday.swift     # Typography scale
│   └── Date+Helpers.swift     # Week navigation, display strings
│
├── Features/
│   ├── Splash/                # Launch screen
│   ├── Onboarding/            # Four-step setup flow
│   ├── SolarSystem/           # Home screen canvas and node views
│   ├── NorthStar/             # Full-screen reveal overlay
│   ├── Someday/               # Reveal, detail, and add views
│   ├── Moments/               # List, detail, and add views
│   └── Settings/              # Preferences and archive management
│
├── Resources/Fonts/           # Bundled TTF files
├── Assets.xcassets/
└── Info.plist
```
