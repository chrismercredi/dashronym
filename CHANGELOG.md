## 0.0.9

- Introduced a shared `TooltipConstraintsResolver` so every tooltip (stock or custom) respects viewport gutters plus new orientation caps: 360 px portrait, 600 px landscape.
- Wrapped inline tooltips with the resolver, ensuring custom builders inherit the same clamp logic while overlays keep the existing follower nudge/scroll dismissal behaviour.
- Expanded unit and widget coverage (100 % lines) with constraint, positioner, orientation-change, and scroll-dismiss tests; refreshed all inline goldens.
- Replaced the published screenshots with the latest portrait/landscape captures and updated README guidance to highlight the new sizing rules.

## 0.0.8

- Fixed pubspec screenshot metadata quoting for pub.dev

## 0.0.7

- Added annotated screenshots and an animated tooltip walkthrough to the package metadata so pub.dev showcases behavior.
- Expanded pub.dev topics with acronym and accessibility tags to improve discoverability.
- Documented localization constructors to maintain full dartdoc coverage for pub scoring.
- Updated README installation instructions to reference version 0.0.7.

## 0.0.6

- Clamp inline tooltip overlays so they stay within the visible viewport on mobile, desktop, and when the window resizes.
- Made tooltip positioning responsive to safe areas, keyboard insets, and RTL layouts, and prevented teardown setState calls.
- Added regression test coverage for the viewport-clamping behavior.

## 0.0.5

- Expanded dartdoc coverage across public APIs, including constructors and library documentation.
- Clarified usage examples for `DashronymText`, `Text.dashronyms`, and configuration helpers.
- Ran `dart format` on source and tests to keep style aligned with Flutter guidelines.

## 0.0.4

- Added configurable hover hide delay and tooltip fade duration to `DashronymTheme`.
- Introduced animated tooltip dismissal with fade transitions and deferred hover hide timers.
- Improved focus handling to auto-show tooltips and prevent lingering overlays when unmounted.
- Excluded tests from static analysis to speed up local iteration and updated theme tests for new fields.

## 0.0.3

- Refactored inline tooltip widgets for richer semantics and accessibility.
- Added localizations, theme customization options, and comprehensive tests.
- Expanded the example app with advanced customization and localization demos.

## 0.0.2

- Applied `dart format .` and refreshed documentation to align with pub.dev publishing guidelines.

## 0.0.1

- Initial release with `Text.dashronyms()` extension, `DashronymText` widget, and configurable registry/theme support.
