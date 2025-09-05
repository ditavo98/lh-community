import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/utils/community_button.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_scaffold.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/display_util.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/text_style.dart';
import 'package:lh_community/src/utils/toast.dart';

class AppDialog {
  static Future showModalBottom(
    BuildContext context, {
    double? heightFactor,
    Widget? child,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 5,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (heightFactor != null) {
          return FractionallySizedBox(
            heightFactor: heightFactor,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Dimen.bottomSheet,
                  topLeft: Dimen.bottomSheet,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: child,
            ),
          );
        }
        return Wrap(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Dimen.bottomSheet,
                  topLeft: Dimen.bottomSheet,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: child,
            ),
          ],
        );
      },
    );
  }

  static Future showModalBottomDrag(
    BuildContext context, {
    initialChildSize = 0.7,
    minChildSize = 0.4,
    maxChildSize = 1.0,
    bool shouldCloseOnMinExtent = false,
    Widget Function(BuildContext, ScrollController)? builder,
    bool isDismissible = true,
    bool isAutoAddHeader = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      elevation: 5,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            context.hideKeyboard();
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    context.hideKeyboard();
                    if (isDismissible) Navigator.pop(context);
                  },
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: initialChildSize,
                minChildSize: minChildSize,
                maxChildSize: maxChildSize,
                shouldCloseOnMinExtent: shouldCloseOnMinExtent,
                builder: (_, controller) {
                  if (isAutoAddHeader) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Dimen.bottomSheet,
                          topLeft: Dimen.bottomSheet,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 20),
                      child: builder?.call(_, controller),
                    );
                  }
                  return SizedBox(child: builder?.call(_, controller));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<dynamic> showAlertDialog({
    BuildContext? context,
    String? title,
    String? subTitle,
    String? message,
    String? acceptText,
    String? cancelText,
    bool barrierDismissible = true,
    bool isButtonOnRow = true,
    Widget? child,
    Widget? acceptChild,
    Widget? additionalBtn,
    Function()? acceptedCallback,
    Function()? canceledCallback,
    Color? acceptBgColor,
    Color? acceptTextColor,
    Color? cancelBorderColor,
    Color? messageColor,
    TextStyle? subTextStyle,
    double hzPadding = Dimen.marginX2_5,
  }) async {
    acceptBgColor ??= CMColor.primary5;
    acceptTextColor ??= CMColor.white;
    cancelBorderColor ??= CMColor.grey3;
    messageColor ??= CMColor.grey7;

    acceptText ??= str.text_check;
    final ctx = context ?? LHCommunity().context;
    dynamic result = await showDialog(
      barrierDismissible: barrierDismissible,
      context: ctx,
      builder: (BuildContext dialogContext) {
        Widget acceptButton = acceptText == null
            ? const SizedBox()
            : CMAppButton(
                text: acceptText,
                onTap: () async {
                  if (acceptedCallback != null) return acceptedCallback.call();
                  Navigator.of(ctx).pop(true);
                },
                backgroundColor: acceptBgColor,
                textColor: acceptTextColor,
                radius: 8,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: acceptChild,
              );
        Widget cancelButton = cancelText == null
            ? const SizedBox()
            : CMAppButton.outline(
                text: cancelText,
                onTap: () {
                  if (canceledCallback != null) return canceledCallback.call();
                  Navigator.of(ctx).pop(false);
                },
                borderColor: cancelBorderColor,
                backgroundColor: Colors.transparent,
                textColor: CMColor.grey6,
                radius: 8,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              );
        Widget padding = const SizedBox.shrink();
        if (cancelText != null && acceptText != null) {
          padding = isButtonOnRow
              ? const SizedBox(width: Dimen.margin)
              : const SizedBox(height: Dimen.marginX2);
        }

        var button = isButtonOnRow
            ? Row(
                children: [
                  cancelText != null
                      ? Expanded(child: cancelButton)
                      : const SizedBox.shrink(),
                  padding,
                  Expanded(child: acceptButton),
                  padding,
                  additionalBtn != null
                      ? Expanded(child: additionalBtn)
                      : const SizedBox.shrink(),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  acceptButton,
                  padding,
                  cancelButton,
                  additionalBtn != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [padding, additionalBtn],
                        )
                      : const SizedBox.shrink()
                ],
              );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: CMScaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.center,
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: maxWidthPopup + (Dimen.marginX4 * 2)),
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () =>
                          barrierDismissible ? Navigator.of(ctx).pop() : null,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(color: Colors.transparent),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(Dimen.marginX2),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.white,
                              ),
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Dimen.dialogRadius24),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: hzPadding,
                                          vertical: Dimen.marginX2,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            child ?? const SizedBox.shrink(),
                                            _dialogTitle(title, child),
                                            _dialogSubTitle(
                                                subTitle, child, subTextStyle),
                                            _dialogMessage(
                                                message, child, messageColor!),
                                            if (cancelText != null ||
                                                acceptText != null ||
                                                additionalBtn != null)
                                              const SizedBox(
                                                  height: Dimen.marginX2),
                                            button,
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    return result;
  }

  static Widget _dialogSubTitle(
      String? s, Widget? child, TextStyle? subTextStyle) {
    if (s == null || child != null) return const SizedBox.shrink();
    return Column(
      children: [
        Text(
          s,
          textAlign: TextAlign.center,
          style: subTextStyle ??
              LHTextStyle.button1.copyWith(color: CMColor.black),
        ),
        const SizedBox(height: Dimen.marginX3),
      ],
    );
  }

  static Widget _dialogTitle(String? s, Widget? child) {
    if (s == null || child != null) return const SizedBox.shrink();
    return Column(
      children: [
        Text(
          s,
          textAlign: TextAlign.center,
          style: LHTextStyle.button1.copyWith(color: CMColor.black),
        ),
        const SizedBox(height: Dimen.marginX1_5),
      ],
    );
  }

  static Widget _dialogMessage(String? message, Widget? child, Color color) {
    if (message == null || child != null) return const SizedBox.shrink();
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: LHTextStyle.body3.copyWith(color: color),
        ),
      ],
    );
  }

  static Future<dynamic> showFailedAlertDialog({
    required BuildContext context,
    String? title,
    String? message,
    String? acceptText,
    String? cancelText,
    Function()? acceptedCallback,
    Function()? canceledCallback,
  }) {
    return showAlertDialog(
      context: context,
      messageColor: CMColor.error,
      title: title ?? str.text_notice,
      message: message,
      acceptText: acceptText ?? str.text_check,
      cancelText: cancelText,
      acceptedCallback: acceptedCallback,
      canceledCallback: canceledCallback,
    );
  }

  static showSuccessToast({
    BuildContext? context,
    required String msg,
    Widget? leading,
  }) {
    ToastUtil.show(
      context ?? LHCommunity().context,
      backgroundRadius: 8,
      child: Row(
        children: [
          if (leading != null) leading,
          if (leading != null) Dimen.sBWidth4,
          Flexible(
            child: Text(
              msg,
              style: TextStyle(color: CMColor.white),
            ),
          ),
        ],
      ),
      background: CMColor.grey8,
    );
  }

  static showFailedToast({
    BuildContext? context,
    required String msg,
    int duration = ToastUtil.medium,
  }) {
    ToastUtil.show(
      LHCommunity().context,
      backgroundRadius: 50,
      duration: duration,
      child: Row(
        children: [
          Icon(Icons.info, size: 16, color: CMColor.white),
          Dimen.sBWidth4,
          Flexible(
            child: Text(
              msg,
              style: TextStyle(color: CMColor.white),
            ),
          ),
        ],
      ),
      background: CMColor.error,
    );
  }

  static Future<T?> showPopupView<T extends Object?>(
    BuildContext context, {
    double? offsetLeft,
    double? offsetRight,
    double width = 100,
    double height = 50,
    EdgeInsetsGeometry? padding,
    List<T> dataList = const [],
    Widget Function(BuildContext ctx, T item)? itemBuilder,
    Color bgColor = Colors.white,
  }) {
    context.hideKeyboard();
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset offset = box.localToGlobal(Offset.zero);
    return showMenu(
      context: LHCommunity().context,
      elevation: 0.0,
      color: Colors.transparent,
      position: RelativeRect.fromLTRB(
        offsetLeft ?? offset.dx,
        offset.dy + height,
        offsetRight ?? Dimen.marginX2,
        0,
      ),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Dimen.radius12),
              color: bgColor,
              boxShadow: [
                const BoxShadow(
                  offset: Offset(0, 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                  color: Color(0x30656565),
                ),
              ],
            ),
            child: ListView.separated(
              padding: padding ?? const EdgeInsets.all(12),
              itemBuilder: (ctx, index) {
                return itemBuilder?.call(ctx, dataList[index]) ??
                    const SizedBox.shrink();
              },
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (ctx, index) => Divider(color: CMColor.grey3),
              itemCount: dataList.length,
            ),
          ),
        ),
      ],
    );
  }

  static Future showCupertinoActionSheet(
    BuildContext ctx, {
    Widget? cancelWidget,
    VoidCallback? onCancel,
    List<Widget>? actions,
  }) {
    return showCupertinoModalPopup(
      context: ctx,
      builder: (ctx) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: Dimen.isTablet ? 100 : 0),
          child: CupertinoActionSheet(
            actions: actions,
            cancelButton: cancelWidget != null
                ? CupertinoActionSheetAction(
                    child: cancelWidget,
                    onPressed: () {
                      onCancel?.call();
                      Navigator.pop(ctx);
                    },
                  )
                : null,
          ),
        );
      },
    );
  }

  static Future alertMediaPermission(BuildContext context) async {
    dynamic isAccept = await showAlertDialog(
      context: context,
      title: str.filesAndPhotos,
      message: str.youCanSharePhotosAndFilesInYourProfileSettingsAndChat,
      acceptText: str.text_check,
      cancelText: str.text_cancel,
    );
    if (isAccept) {
      await AppSettings.openAppSettings(type: AppSettingsType.settings);
    }
  }
}
