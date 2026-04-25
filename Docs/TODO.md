# Someday: Roadmap

Features planned for upcoming releases.

---

## Shooting Stars

A release mechanic for fleeting thoughts, worries, or things the user wants to get off their chest. Write it, fire it off into space, and it's gone.

- Create `ShootingStar` SwiftData model (`thought: String`, `createdAt: Date`)
- Create shooting star input sheet, accessible from the home "+" menu
- Animate the text across the canvas along a curved path, fading out at the edge
- Register `ShootingStar` in the `ModelContainer` schema
- Optional soft haptic pulse on fire

---

## Moment Photo Attachments

The `Moment` model already stores a `photoPath` string; the capture and display UI is not yet built.

- Add a photo picker (`PhotosUI.PhotosPicker`) to `AddMomentView`
- Save the selected image to the app's documents directory and store the relative path
- Display a photo thumbnail in `MomentDetailView` when `photoPath` is non-nil

---

## Someday Ordering

The `SomedayItem` model has a `sortOrder` field, but there is no drag-to-reorder UI.

- Implement drag-to-reorder on the Someday list
- Persist the new order via `sortOrder`

---

## Polish

- [x] **Empty state**: if the user has no Somedays, show the North Star only with the message _"It's looking pretty empty out here!"_
- [x] **North Star reveal**: verify the "You contributed to N somedays this month" dot row in `NorthStarRevealView` is driven by real SwiftData queries, not placeholder data
