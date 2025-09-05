import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/num_ex.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:lh_community/src/utils/text_style.dart';

class CMFormField extends StatelessWidget {
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final int? maxLines;
  final Color? fillColor;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final InputBorder? inputBorder;
  final InputBorder? focusedBorder, focusedErrorBorder;
  final Function(String)? onChanged;
  final Function()? onTap;
  final TextAlign textAlign;
  final String? labelText;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool readOnly;
  final bool obscureText;
  final TextStyle? textStyle;
  final bool autofocus;
  final Widget? error;
  final String? errorText;
  final int? errorMaxLines, hintMaxLines;
  final TextStyle? errorStyle;
  final InputBorder? errorBorder;
  final TextStyle? hintStyle, counterStyle;
  final Widget? counter;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool? enabled, isDense;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode autovalidateMode;

  CMFormField({
    super.key,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.fillColor,
    this.controller,
    this.contentPadding,
    this.keyboardType,
    this.validator,
    this.inputBorder,
    this.focusedBorder,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.onChanged,
    this.labelText,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.initialValue,
    this.inputFormatters,
    this.maxLength,
    this.readOnly = false,
    this.obscureText = false,
    this.textStyle,
    this.autofocus = false,
    this.error,
    this.errorText,
    this.errorStyle,
    this.errorBorder,
    this.hintStyle,
    this.errorMaxLines = 1,
    this.counter,
    this.focusNode,
    this.textInputAction,
    this.enabled,
    this.onFieldSubmitted,
    this.focusedErrorBorder,
    this.counterStyle,
    this.suffixIconConstraints,
    this.isDense = false,
    this.hintMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autofocus,
      focusNode: focusNode,
      maxLines: maxLines,
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      textAlign: textAlign,
      textAlignVertical: TextAlignVertical.center,
      initialValue: initialValue,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      obscureText: obscureText,
      style: textStyle,
      obscuringCharacter: '●',
      textInputAction: textInputAction,
      enabled: enabled,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        filled: true,
        isDense: isDense,
        fillColor: fillColor ?? CMColor.background1,
        hintText: hintText,
        labelText: labelText,
        counter: counter,
        counterStyle: counterStyle,
        contentPadding: contentPadding ?? const EdgeInsets.all(11),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixIconConstraints: suffixIconConstraints,
        hintStyle: hintStyle ??
            LHTextStyle.body2.copyWith(color: CMColor.grey7.withOpacity(.5)),
        error: error,
        hintMaxLines: hintMaxLines,
        errorText: errorText,
        errorMaxLines: errorMaxLines,
        errorStyle: errorStyle,
        errorBorder: errorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: CMColor.error),
            ),
        labelStyle: LHTextStyle.body4.copyWith(
          color: CMColor.error,
        ),
        border: inputBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: CMColor.grey3),
            ),
        focusedBorder: focusedBorder ??
            (inputBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: CMColor.grey3),
                )),
        focusedErrorBorder: focusedErrorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: CMColor.error),
            ),
        enabledBorder: inputBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: CMColor.grey3),
            ),
      ),
    );
  }

  static TextInputFormatter denyWhiteSpace =
      FilteringTextInputFormatter.deny(RegExp(r'\s'));

  static Widget counterView(
      TextEditingController ctl, int maxLength, TextStyle counterStyle) {
    return ValueListenableBuilder(
      valueListenable: ctl,
      builder: (context, value, _) {
        return Text('${value.text.length}/${maxLength.toCurrency}',
            style: counterStyle);
      },
    );
  }
}

class AppSearchTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueSetter<String>? onSearch;
  final InputBorder? inputBorder, focusedBorder;
  final EdgeInsetsGeometry? contentPadding;
  final Duration time;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final Color? iconColor;
  final FocusNode? focusNode;
  final Widget? prefixIcon;

  const AppSearchTextField({
    super.key,
    this.onSearch,
    this.controller,
    this.hint,
    this.inputBorder,
    this.contentPadding,
    this.time = const Duration(milliseconds: 500),
    this.fillColor,
    this.hintStyle,
    this.iconColor,
    this.focusNode,
    this.prefixIcon,
    this.focusedBorder,
  });

  @override
  State<AppSearchTextField> createState() => _AppSearchTextFieldState();
}

class _AppSearchTextFieldState extends State<AppSearchTextField> {
  Timer? _timer;
  final ValueNotifier<bool> _haveSearchValue = ValueNotifier(false);

  late TextEditingController _searchController;

  @override
  void initState() {
    _searchController = widget.controller ?? TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _haveSearchValue,
      builder: (context, haveData, _) {
        return CMFormField(
          focusNode: widget.focusNode,
          hintText: widget.hint,
          controller: _searchController,
          fillColor: widget.fillColor ?? CMColor.background1,
          textInputAction: TextInputAction.done,
          prefixIcon: widget.prefixIcon,
          hintStyle: widget.hintStyle ??
              LHTextStyle.body2.copyWith(color: CMColor.grey7),
          focusedBorder: widget.focusedBorder,
          suffixIcon: haveData
              ? GestureDetector(
                  onTap: () {
                    _haveSearchValue.value = false;
                    _searchController.text = '';
                    widget.onSearch?.call('');
                  },
                  child: CMImageView(
                    cmSvg.icCloseCircle,
                    width: Dimen.iconBtnSize,
                    height: Dimen.iconBtnSize,
                    color: widget.iconColor ?? CMColor.grey7,
                    fit: BoxFit.scaleDown,
                  ),
                )
              : null,
          inputBorder: widget.inputBorder ?? InputBorder.none,
          onChanged: (v) {
            _timer?.cancel();
            _timer = Timer(widget.time, () async {
              widget.onSearch?.call(v.trim());
            });
            if (v.notNullOrEmpty) {
              _haveSearchValue.value = true;
              return;
            }
            _haveSearchValue.value = false;
          },
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 10),
        );
      },
    );
  }

  @override
  void dispose() {
    _haveSearchValue.dispose();
    _timer?.cancel();
    if (widget.controller == null) {
      _searchController.dispose();
    }
    super.dispose();
  }
}
