import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';


class CMScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final bool extendBody;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final EdgeInsetsGeometry? bodyPadding;
  final bool autoBodyPaddingImp;
  final bool applyPaddingDefault;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const CMScaffold({
    super.key,
    this.body,
    this.appBar,
    this.extendBody = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.bodyPadding,
    this.autoBodyPaddingImp = true,
    this.bottomNavigationBar,
    this.applyPaddingDefault = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: _body(context),
      extendBody: extendBody,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget? _body(BuildContext context) {
    Widget? widget = body;
    if (applyPaddingDefault) {
      widget = Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: body,
        ),
      );
    }
    if (autoBodyPaddingImp) {
      widget = Padding(
        padding: bodyPadding ?? Dimen.scaffoldPadding,
        child: body,
      );
    }
    return widget;
  }
}
