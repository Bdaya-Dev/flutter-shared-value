## [4.0.0]

### Breaking Changes

* Minimum Dart SDK raised to >=3.5.0 (Dart 3 required).
* Minimum Flutter SDK raised to >=3.22.0.
* Upgraded rxdart to ^0.28.0.
* Upgraded shared_preferences to ^2.5.0.

### Added

* CI pipeline via GitHub Actions (stable + beta Flutter channels).
* Automated pub.dev publishing via trusted publishing (OIDC).
* Comprehensive test suite covering the SharedValue API, streams, persistence, and widgets.
* Static analysis with flutter_lints.
* Automated version management via release-please (conventional commits).
* Semantic PR title enforcement.

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
