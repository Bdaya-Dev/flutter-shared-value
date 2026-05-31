import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'inherited_model.dart';

class StateManagerWidget extends StatefulWidget {
  static final _changedKeys = <int>{};
  static Future<void> Function()? _rebuild;

  static void markChanged(int key) {
    _changedKeys.add(key);
  }

  static Future<void> triggerRebuild() async {
    await _rebuild?.call();
  }

  final Widget child;

  const StateManagerWidget({super.key, required this.child});

  @override
  State<StateManagerWidget> createState() => _StateManagerWidgetState();
}

class _StateManagerWidgetState extends State<StateManagerWidget> {
  @override
  void initState() {
    super.initState();
    StateManagerWidget._rebuild = _doRebuild;
  }

  @override
  void dispose() {
    if (StateManagerWidget._rebuild == _doRebuild) {
      StateManagerWidget._rebuild = null;
    }
    super.dispose();
  }

  Future<void> _doRebuild() async {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final changed = Set<int>.of(StateManagerWidget._changedKeys);
    StateManagerWidget._changedKeys.clear();
    return SharedValueInheritedModel(changedKeys: changed, child: widget.child);
  }
}
