import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/text_style.dart';

class CMDropdown<T> extends StatelessWidget {
  final T? initialValue;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final Widget Function(int index) itemTitleBuilder;
  final T Function(int index) valueGetter;
  final int itemCount;
  final double? width, height, dropdownWidth;
  final Radius radius;
  final Color? borderColor, color, dropdownBgColor;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final DropdownButtonBuilder? selectedItemBuilder;

  const CMDropdown({
    super.key,
    this.initialValue,
    this.selectedValue,
    required this.onChanged,
    this.hint,
    required this.itemTitleBuilder,
    required this.itemCount,
    required this.valueGetter,
    this.width,
    this.radius = Dimen.radius10,
    this.borderColor,
    this.color = Colors.transparent,
    this.height,
    this.padding,
    this.dropdownBgColor,
    this.icon,
    this.dropdownWidth,
    this.selectedItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<T>(
      value: initialValue,
      style: LHTextStyle.body3,
      onChanged: onChanged,
      underline: const SizedBox(),
      iconStyleData: IconStyleData(
        icon: icon ??
            CMImageView(
              cmSvg.icArrowDown,
              fit: BoxFit.scaleDown,
              size: 16,
            ),
      ),
      hint: hint != null ? Text(hint!, style: LHTextStyle.body4) : null,
      buttonStyleData: ButtonStyleData(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? CMColor.grey3),
          borderRadius: BorderRadius.all(radius),
          color: color,
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
        width: width ?? double.infinity,
        height: height,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(radius),
          color: dropdownBgColor ?? CMColor.white,
        ),
        scrollPadding: const EdgeInsets.only(),
        offset: const Offset(0, -8),
        elevation: 16,
        width: dropdownWidth,
      ),
      selectedItemBuilder: _selectedItem,
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.zero,
        customHeights: List.generate(
          itemCount + (itemCount - 1).abs(),
          (index) {
            if (index % 2 == 1) {
              return 1;
            }
            return 40;
          },
        ),
      ),
      items: List.generate(
        itemCount + (itemCount - 1).abs(),
        (index) {
          final realIndex = (index / 2).round();
          if (index % 2 == 1) {
            return DropdownMenuItem(
              enabled: false,
              child:  Divider(
                height: 1,
                color: CMColor.grey3,
              ),
            );
          }
          return DropdownMenuItem<T>(
            value: valueGetter(realIndex),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: itemTitleBuilder(realIndex),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _selectedItem(BuildContext context) {
    if (selectedItemBuilder == null) return [];
    var widgets = selectedItemBuilder!(context);
    for (var i = widgets.length; i-- > 1;) {
      widgets.insert(i, const Row(children: [SizedBox.shrink()]));
    }
    return widgets;
  }
}
