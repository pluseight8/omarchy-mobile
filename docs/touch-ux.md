# Touch UX specification

This is a staged specification. The prototype implements only the items marked “present now”; the remaining behaviors are targets and must not be represented as working.

## Present now

| Interaction | Prototype behavior |
| --- | --- |
| Tap app card | Launch through Omarchy's scoped application-library facade |
| Scroll app list | Flickable GridView |
| Long press app card | Show an app details panel and launch action |
| Search | Filter via the same upstream application library |
| Dismiss | On-screen Close control; Escape when the search field has focus |
| Target size | Controls derive a minimum hit area from Style.space(48) |

The grid derives its columns from current logical width. It does not use Pixel's physical resolution as a QML window size.

## Target behavior not yet implemented

- Swipe up to home, swipe-and-hold to overview, horizontal workspace swipe, edge-back, and top system panel.
- Arbitration rules when app content also owns edge and horizontal gestures.
- A mobile workspace model that reuses Hyprland and Omarchy window management.
- Keyboard show/hide integration using the active Wayland input-method and text-input protocols supported by the selected compositor.
- Keyboard-aware resize or inset behavior that keeps the focused field visible.
- Safe-area, display cutout, rotation, touch-coordinate transform, and scale handling.
- Mobile notification center, control panels, clipboard, media controls, lock screen, and power controls.
- External display and physical keyboard/mouse transitions.

## Validation before calling it mobile-ready

1. Run the pinned Omarchy shell and Quickshell plugin on an ARM64 Linux session.
2. Test taps, long press, flick, search, focus, close, and launch with touch input.
3. Test portrait and landscape at multiple compositor scales, including long labels and an open virtual keyboard.
4. Record screenshots and touch traces; verify no controls fall outside the output.
5. Test gesture conflicts against representative applications and document the compositor-specific arbitration.
6. Repeat critical interaction tests on Pixel 10 only after its display and input stack is independently functional.

No visual screenshot or hardware interaction has yet been captured for this repository.
