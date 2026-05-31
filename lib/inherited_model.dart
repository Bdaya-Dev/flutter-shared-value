import 'package:flutter/widgets.dart';

class SharedValueInheritedModel extends InheritedModel<int> {
  final Set<int> changedKeys;

  const SharedValueInheritedModel({
    super.key,
    required super.child,
    required this.changedKeys,
  });

  @override
  bool updateShouldNotify(SharedValueInheritedModel oldWidget) =>
      changedKeys.isNotEmpty;

  @override
  bool updateShouldNotifyDependent(
    SharedValueInheritedModel oldWidget,
    Set<int> dependencies,
  ) {
    return dependencies.any(changedKeys.contains);
  }
}
