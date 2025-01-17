import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class SharedValueInheritedModel extends InheritedModel<int> {
  final Map<int, double> stateNonceMap;

  const SharedValueInheritedModel({
    Key? key,
    required Widget child,
    required this.stateNonceMap,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(SharedValueInheritedModel oldWidget) =>
      !mapEquals(oldWidget.stateNonceMap, stateNonceMap);

  @override
  bool updateShouldNotifyDependent(
    SharedValueInheritedModel oldWidget,
    Set<int> dependencies,
  ) {
    // Compare the nonce value of this SharedValue,
    // with an older nonce value of the same SharedValue object.
    //
    // If the nonce values are not same,
    // rebuild the widget
    return dependencies.any(
      (sharedValueHash) =>
          stateNonceMap[sharedValueHash] !=
          oldWidget.stateNonceMap[sharedValueHash],
    );
  }
}
