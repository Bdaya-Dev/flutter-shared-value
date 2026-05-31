# Changelog

## [4.0.0](https://github.com/Bdaya-Dev/flutter-shared-value/compare/v3.1.3...v4.0.0) (2026-05-30)

### ⚠ BREAKING CHANGES

* Minimum Dart SDK raised to >=3.8.0 (Dart 3 required).
* Minimum Flutter SDK raised to >=3.32.0.
* Upgraded rxdart to >=0.28.0 <2.0.0 (unblocks package:oidc rxdart 0.28 upgrade).
* Upgraded shared_preferences to ^2.5.0.

### Features

* Comprehensive test suite (24 tests) covering SharedValue API, streams, persistence, custom encode/decode, widgets, and InheritedModel.
* CI pipeline via GitHub Actions (stable + beta Flutter channels).
* Automated pub.dev publishing via trusted publishing (OIDC) with release-please.
* Static analysis with flutter_lints.
* Semantic PR title enforcement.
* Dependabot for pub + GitHub Actions dependency updates.

### Miscellaneous

* Apply dart format tall style for Dart 3.8+ compatibility ([b15c30b](https://github.com/Bdaya-Dev/flutter-shared-value/commit/b15c30b1ac8b4126dfa88f2b2b6a5152ff09c5ed))

## [3.1.3] - 03/11/2022

* `customEncode` and `customDecode` can now handle null strings, indicating that the key does not exist in the storage

## [3.1.2] - 26/10/2022

* Fixed `streamWithInitial` with rxdart

## [3.1.1] - 26/10/2022

* Fixed `streamWithInitial`

## [3.1.0] - 23/10/2022

* Add support for custom save/load logic
* Fixed memory leak due to `SharedValue` instances not being garbage collected because of the nonce map `Map<SharedValue, double>`
* Implemented `updateShouldNotify` in `SharedValueInheritedModel`
