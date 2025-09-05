import 'package:flutter/material.dart';

class UnFocus extends StatelessWidget {
  const UnFocus({super.key, required this.child});

  final Widget child;

  static call() {
    if (primaryFocus != null) primaryFocus!.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: call,
      child: child,
    );
  }
}

class DisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
