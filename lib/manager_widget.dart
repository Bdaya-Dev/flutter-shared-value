import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'inherited_model.dart';

class StateManagerWidget extends StatefulWidget {
  final Widget child;
  final StateManagerWidgetState state;
  final Map<int, double> stateNonceMap;

  const StateManagerWidget(
    this.child,
    this.state,
    this.stateNonceMap, {
    super.key,
  });

  @override
  // ignore: no_logic_in_create_state
  StateManagerWidgetState createState() => state;
}

class StateManagerWidgetState extends State<StateManagerWidget> {
  Future<void> rebuild() async {
    if (!mounted) return;

    // if there's a current frame,
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      // wait for the end of that frame.
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SharedValueInheritedModel(
      // A copy of stateNonceMap must be provided here so that
      // SharedValueInheritedModel can compare old vs new nonce values.
      stateNonceMap: Map.of(widget.stateNonceMap),
      child: widget.child,
    );
  }
}
