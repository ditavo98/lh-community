import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/community_button.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/text_style.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
    this.title,
    this.actions,
    this.isBorder = false,
    this.titleWidget,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.actionLeading,
    this.centerTitle = true,
    this.color,
    this.foregroundColor,
    this.flexibleSpace,
    this.onTap,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  final String? title;
  final List<Widget>? actions;
  final bool isBorder;
  final Widget? titleWidget;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Function()? actionLeading, onTap;
  final bool centerTitle;
  final Color? color;
  final Color? foregroundColor;
  final Widget? flexibleSpace;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppBar(
        backgroundColor: color ?? Colors.white,
        elevation: 0,
        centerTitle: centerTitle,
        leading: _leading(context),
        actions: actions,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: automaticallyImplyLeading,
        titleSpacing: (automaticallyImplyLeading || titleWidget != null) ? 0 : 12,
        title: titleWidget ??
            (title != null ? Text(title!, style: LHTextStyle.subtitle1) : null),
        bottom: isBorder
            ? PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: CMColor.grey3,
                  height: 1.0,
                ),
              )
            : null,
        flexibleSpace: flexibleSpace,
      ),
    );
  }

  Widget? _leading(BuildContext ctx) {
    if (!automaticallyImplyLeading) return null;
    return leading ??
        AppIconButton(
          onPressed: actionLeading ?? Navigator.of(ctx).pop,
          child: CMImageView(
            cmSvg.icBack,
            color: foregroundColor,
            width: Dimen.iconBtnSize,
            height: Dimen.iconBtnSize,
          ),
        );
  }

  @override
  final Size preferredSize;
}
