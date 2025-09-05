import 'dart:ui';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';

extension DisplayExtension on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;

  Orientation get orientation => MediaQuery.of(this).orientation;

  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;

  bool get isPortrait => orientation == Orientation.portrait;

  FlutterView get flutterView => View.of(this);

  double get screenWidthPx => flutterView.physicalSize.width;

  double get screenHeightPx => flutterView.physicalSize.height;

  double get statusBarHeight => MediaQuery.viewPaddingOf(this).top;

  double get bottomSafeArea => MediaQuery.viewPaddingOf(this).bottom;

  double get keyboardHeight => MediaQuery.viewInsetsOf(this).bottom;

  double get topPadding => MediaQuery.viewInsetsOf(this).top;

  double get bottomPadding => MediaQuery.viewInsetsOf(this).bottom;

  void hideKeyboard() {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
    } catch (_) {}
  }
}


extension DismissibleContextRouterExt on BuildContext {
  /// Navigates to desired page with transparent transition background
  Future<T?> pushTransparentRouteWithRouteSetting<T>(Widget page,
      {Color backgroundColor = Colors.transparent,
        Duration transitionDuration = const Duration(milliseconds: 250),
        Duration reverseTransitionDuration = const Duration(milliseconds: 250),
        bool rootNavigator = false,
        RouteSettings? settings}) {
    return Navigator.of(this, rootNavigator: rootNavigator).push(
      TransparentRoute(
        builder: (_) => page,
        backgroundColor: backgroundColor,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        settings: settings,
      ),
    );
  }

  Future<T?> pushRouteWithRouteSetting<T>(Widget page,
      {bool rootNavigator = false, RouteSettings? settings}) {
    Route<T> createRoute() {
      return PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 150),
        reverseTransitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var scaleTween = Tween(begin: 0.9, end: 1.0);
          var scaleAnimation = animation.drive(scaleTween);
          var fadeAnimation = animation;
          return Center(
            child: ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(opacity: fadeAnimation, child: child),
            ),
          );
        },
        barrierColor: Colors.transparent,
        settings: settings,
      );
    }

    return Navigator.of(this, rootNavigator: rootNavigator).push(createRoute());
  }
}
