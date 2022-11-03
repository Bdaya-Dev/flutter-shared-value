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
