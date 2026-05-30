## [3.1.3] - 03/11/2022

* `customEncode` and `customDecode` can now handle null strings, indicating that the key does not exist in the storage

## [4.0.0](https://github.com/Bdaya-Dev/flutter-shared-value/compare/v3.1.3...v4.0.0) (2026-05-30)


### ⚠ BREAKING CHANGES

* Minimum Dart SDK raised to >=3.5.0, Flutter >=3.22.0, rxdart bumped to ^0.28.0, shared_preferences to ^2.5.0.

### Features

* modernize to v4.0.0 — Dart 3, rxdart 0.28, CI/CD, tests, release-please ([6cfc8c9](https://github.com/Bdaya-Dev/flutter-shared-value/commit/6cfc8c92c2a701baf020ed81a018b7e07ffbf67c))


### Miscellaneous

* apply dart format tall style for Dart 3.8+ compatibility ([b15c30b](https://github.com/Bdaya-Dev/flutter-shared-value/commit/b15c30b1ac8b4126dfa88f2b2b6a5152ff09c5ed))

## [3.1.2] - 26/10/2022

* Fixed `streamWithInitial` with rxdart

## [3.1.1] - 26/10/2022

* Fixed `streamWithInitial`

## [3.1.0] - 23/10/2022

* Add support for custom save/load logic
* Fixed memory leak due to `SharedValue` instances not being garbage collected because of the nonce map `Map<SharedValue, double>`
* Implemented `updateShouldNotify` in `SharedValueInheritedModel`
