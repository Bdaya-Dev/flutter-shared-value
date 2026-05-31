# Changelog

## [5.0.1](https://github.com/Bdaya-Dev/flutter-shared-value/compare/v5.0.0...v5.0.1) (2026-05-31)


### Bug Fixes

* remove example/.metadata from git tracking ([10edbbd](https://github.com/Bdaya-Dev/flutter-shared-value/commit/10edbbd0df2a2a1b949ef01419bcec5f80bd1d08))

## [5.0.0](https://github.com/Bdaya-Dev/flutter-shared-value/compare/v4.0.0...v5.0.0) (2026-05-31)


### ⚠ BREAKING CHANGES

* persistence API removed entirely (load, save, key, autosave, customEncode, customDecode, customSave, customLoad, serialize, deserialize, SharedValueStorage). Use external persistence solutions and set SharedValue.$ directly.
* shared_preferences is no longer a dependency. load()/save() require customSave/customLoad callbacks. Users who relied on the built-in SharedPreferences persistence must provide their own callbacks.
* rxdart is no longer a transitive dependency. Consumers who relied on rxdart being pulled in transitively must add it directly.

### Features

* clean API redesign — remove persistence, optimize internals ([145c65f](https://github.com/Bdaya-Dev/flutter-shared-value/commit/145c65f3d6bdee802f7c465707840de98efbfbcf))
* remove rxdart dependency ([7b8a6ec](https://github.com/Bdaya-Dev/flutter-shared-value/commit/7b8a6ec1437683376938ea37679aff206d9615b7))
* remove shared_preferences dependency, make persistence pluggable ([5906895](https://github.com/Bdaya-Dev/flutter-shared-value/commit/590689567c63406850e1041685b4a0525d13b078))


### Bug Fixes

* add # Changelog header to fix release-please insertion order ([7815ec7](https://github.com/Bdaya-Dev/flutter-shared-value/commit/7815ec7a197225c7caccf4de24dea5c68d59ed6b))


### Miscellaneous

* clean up .gitignore and remove tracked IDE/generated files ([b2438b3](https://github.com/Bdaya-Dev/flutter-shared-value/commit/b2438b32feb009e53faf7e9eac10f411088be8a3))

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
