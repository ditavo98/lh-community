import 'package:flutter/cupertino.dart';

class Dimen {
  static const double marginD4 = 2;
  static const double marginD2 = 4;
  static const double margin6 = 6;
  static const double margin = 8;
  static const double margin10 = 10;
  static const double marginX1_5 = margin * 1.5;
  static const double marginX2 = margin * 2;
  static const double marginX2_5 = margin * 2.5;
  static const double marginX3 = margin * 3;
  static const double marginX4 = margin * 4;
  static const double marginX5 = margin * 5;
  static const double marginX6 = margin * 6;
  static const double marginX7 = margin * 7;
  static const double marginX8 = margin * 8;
  static const Radius imageRadius = Radius.circular(8);
  static const Radius imageRadiusX2 = Radius.circular(16);
  static const double iconSize = 16;
  static const double iconSize20 = 20;
  static const double iconBtnSize = 24;
  static const double iconMediumSize = 36;
  static const double iconBtnLargeSize = 40;

  static const double imageLogoSize = 68;
  static const double imageSmallLogoSize = 70;
  static const double imageBigSize = 120;
  static const double imageSize144 = 144;
  static const double imageSize64 = 64;
  static const double imageAvatar = 56;
  static const double imageAvatar72 = 72;

  static const double scanBtnSize = 68;

  static const double screenPadding = 16;
  static const EdgeInsetsGeometry scaffoldPaddingWithoutTop =
      EdgeInsets.fromLTRB(
          Dimen.screenPadding, 0, Dimen.screenPadding, Dimen.screenPadding + 8);
  static const EdgeInsetsGeometry scaffoldPaddingHz =
      EdgeInsets.fromLTRB(Dimen.screenPadding, 0, Dimen.screenPadding, 0);
  static const EdgeInsetsGeometry scaffoldPadding = EdgeInsets.fromLTRB(
    Dimen.screenPadding,
    Dimen.screenPadding,
    Dimen.screenPadding,
    Dimen.screenPadding + 8,
  );
  static const EdgeInsetsGeometry hzPadding =
      EdgeInsets.symmetric(horizontal: Dimen.screenPadding);

  static const double btnHzPadding = 15;
  static const double btnVtPadding = 7;

  static const Radius btnRadius = Radius.circular(12);

  static const Radius bottomSheet = Radius.circular(32);

  static const Radius radius8 = Radius.circular(8);
  static const Radius radius10 = Radius.circular(10);
  static const Radius radius12 = Radius.circular(12);
  static const Radius radius16 = Radius.circular(16);
  static const Radius radius20 = Radius.circular(20);
  static const Radius radius24 = Radius.circular(24);
  static const Radius dialogRadius24 = Radius.circular(24);
  static const Radius textFieldRadius16 = Radius.circular(16);

  static const Radius bottomNavRadius = Radius.circular(24);

  static const sBWidth4 = SizedBox(width: 4);
  static const sBWidth6 = SizedBox(width: 6);
  static const sBWidth8 = SizedBox(width: 8);
  static const sBWidth12 = SizedBox(width: 12);
  static const sBWidth16 = SizedBox(width: 16);
  static const sBWidth24 = SizedBox(width: 24);

  static const sBHeight4 = SizedBox(height: 4);
  static const sBHeight8 = SizedBox(height: 8);
  static const sBHeight12 = SizedBox(height: 12);
  static const sBHeight16 = SizedBox(height: 16);
  static const sBHeight24 = SizedBox(height: 24);
  static const sBBottomBarHeight = SizedBox(height: bottomBarHeight);
  static const double bottomBarHeight = 64 + 20;

  static ScreenType get getDeviceType {
    final shortestSide = screenSize.shortestSide;
    if (shortestSide >= 600) {
      return ScreenType.tablet;
    } else {
      return ScreenType.regular;
    }
  }

  static Size get screenSize {
    Size data = MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.single)
        .size;
    return data;
  }

  static bool get isTablet {
    return screenType == ScreenType.tablet;
  }

  static ScreenType get screenType => getDeviceType;

  static Size get tabletNavBar => Size(64, 450);
}

enum ScreenType { regular, tablet }
