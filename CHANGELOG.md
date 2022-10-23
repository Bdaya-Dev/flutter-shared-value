## [3.1.0] - 23/10/2022

* Add support for custom save/load logic
* Fixed memory leak due to `SharedValue` instances not being garbage collected because of the nonce map `Map<SharedValue, double>`
* Implemented `updateShouldNotify` in `SharedValueInheritedModel`
