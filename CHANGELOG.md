# Changelog

## [0.5.1] - 2021-07-22

### Fixed

- Fix multiple nested @ rules.

## [0.5.0] - 2021-07-22

### Fixed

- Fix more issues with nested @ rules.

## [0.4.0] - 2021-07-21

### Fixed

- `@font-face` are no longer overly greedy.

## [0.3.0] - 2021-07-21

### Fixed

- `@font-face` is parsed now, as well as any nested at-rule without a value.

## [0.2.0] - 2021-07-11

### Changed

- `CSSerpent.Rule` struct now has a `source` attribute intended to be used to keep track from where rules sourced.

### Added

- Add `raw_css/1` which returns minified CSS.
