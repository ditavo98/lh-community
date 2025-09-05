import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/text_style.dart';

class CMAppButton extends StatelessWidget {
  final String? text;
  final bool enable;
  final Color? borderColor;
  final double? width;
  final double? height;
  final Color? pressColor;
  final Function()? onTap;
  final TextStyle? textStyle;
  final Color? textColor;
  final bool outline;
  final Color? backgroundColor;
  final Widget? leadingWidget, trailingWidget;
  final Widget? child;
  final bool isExpand;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;
  final double? radius;
  final Gradient? gradient;

  const CMAppButton({
    super.key,
    this.text,
    this.enable = true,
    this.borderColor,
    this.width,
    this.height = 56,
    this.pressColor,
    this.onTap,
    this.textStyle,
    this.textColor,
    this.backgroundColor,
    this.leadingWidget,
    this.isExpand = true,
    this.padding,
    this.child,
    this.boxShadow,
    this.radius,
    this.gradient,
    this.trailingWidget,
  }) : outline = false;

  const CMAppButton.outline({
    super.key,
    this.text,
    this.enable = true,
    this.borderColor,
    this.width,
    this.height = 56,
    this.pressColor,
    this.onTap,
    this.textStyle,
    this.backgroundColor,
    this.leadingWidget,
    this.isExpand = true,
    this.padding,
    this.child,
    this.boxShadow,
    this.radius,
    this.textColor,
    this.trailingWidget,
  })  : outline = true,
        gradient = null;

  BoxDecoration get decoration => outline
      ? BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.all(
              radius != null ? Radius.circular(radius!) : Dimen.btnRadius),
          border: Border.all(
            color: enable ? (borderColor ?? CMColor.primary5) : CMColor.grey3,
          ),
        )
      : BoxDecoration(
          color:
              enable ? (backgroundColor ?? CMColor.primary5) : CMColor.grey3,
          boxShadow: boxShadow,
          gradient: gradient,
          borderRadius: BorderRadius.all(
              radius != null ? Radius.circular(radius!) : Dimen.btnRadius),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        );

  @override
  Widget build(BuildContext context) {
    var splashColor =
        pressColor ?? (outline ? CMColor.primary3 : backgroundColor);
    var colorOfText = textColor ?? (enable ? CMColor.white : CMColor.grey7);
    var textStyleValue =
        textStyle ?? LHTextStyle.button1.copyWith(color: colorOfText);
    return Container(
      width: width,
      height: height,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.all(
            radius != null ? Radius.circular(radius!) : Dimen.btnRadius),
        child: RawMaterialButton(
          onPressed: enable
              ? () {
                  onTap?.call();
                }
              : null,
          constraints: const BoxConstraints(minWidth: 60, minHeight: 30),
          splashColor: splashColor,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: child ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: isExpand ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    leadingWidget ?? const SizedBox.shrink(),
                    Flexible(
                      child: Text(
                        text ?? "",
                        style: textStyleValue,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    trailingWidget ?? const SizedBox.shrink(),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}

class AppInkWell extends StatelessWidget {
  final Radius? radius;
  final VoidCallback? onTap;
  final Widget? child;
  final ShapeBorder shape;

  const AppInkWell({
    super.key,
    this.child,
    this.onTap,
    this.radius,
    this.shape = const RoundedRectangleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(radius ?? const Radius.circular(4)),
      child: child,
    );
  }
}

class AppIconButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final bool borderNone;
  final Color? borderColor, color;

  const AppIconButton({
    super.key,
    this.child,
    this.onPressed,
    this.borderNone = true,
    this.borderColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      icon: ClipRRect(
        borderRadius:
            const BorderRadius.all(Radius.circular(Dimen.iconBtnSize / 2)),
        child: Container(
          decoration: BoxDecoration(
            border: borderNone
                ? null
                : Border.all(color: borderColor ?? CMColor.grey3),
            shape: BoxShape.circle,
            color: color,
          ),
          padding: const EdgeInsets.all(Dimen.margin),
          child: child,
        ),
      ),
    );
  }
}

class AppRoundIconButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;

  const AppRoundIconButton({
    super.key,
    this.child,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        decoration: BoxDecoration(
          color: CMColor.black.withAlpha((255.0 * .2).round()),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(
              color: CMColor.white.withAlpha((255.0 * .08).round())),
        ),
        padding: const EdgeInsets.all(Dimen.margin),
        child: child,
      ),
    );
  }
}
