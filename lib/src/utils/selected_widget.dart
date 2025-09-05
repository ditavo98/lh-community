import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/res.dart';

class AppCheckBox extends StatefulWidget {
  final bool initialValue;
  final double size;
  final ValueChanged<bool>? onChange;
  final bool active;

  const AppCheckBox({
    super.key,
    this.initialValue = false,
    this.size = 24,
    this.active = true,
    this.onChange,
  });

  @override
  State<AppCheckBox> createState() => _AppCheckBoxState();
}

class _AppCheckBoxState extends State<AppCheckBox> {
  late bool _value;

  double get size => widget.size;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppCheckBox oldWidget) {
    if (widget.initialValue != _value) {
      setState(() {
        _value = widget.initialValue;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.active
          ? () {
              setState(() {
                _value = !_value;
                widget.onChange?.call(_value);
              });
            }
          : null,
      child: _value
          ? Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CMColor.primary5,
              ),
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.check,
                size: 16,
                weight: 2,
                color: CMColor.white,
              ),
            )
          : Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CMColor.greyN4, width: 2),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                weight: 2,
                color: CMColor.greyN4,
              ),
            ),
    );
  }
}

class AppCheckBox2 extends StatefulWidget {
  final bool initialValue;
  final double size;
  final ValueChanged<bool>? onChange;
  final bool active;

  const AppCheckBox2({
    super.key,
    this.initialValue = false,
    this.size = 24,
    this.active = true,
    this.onChange,
  });

  @override
  State<AppCheckBox2> createState() => _AppCheckBoxState2();
}

class _AppCheckBoxState2 extends State<AppCheckBox2> {
  late bool _value;

  double get size => widget.size;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppCheckBox2 oldWidget) {
    if (widget.initialValue != _value) {
      setState(() {
        _value = widget.initialValue;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.active
          ? () {
              setState(() {
                _value = !_value;
                widget.onChange?.call(_value);
              });
            }
          : null,
      child: _value
          ? Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CMColor.primary5,
              ),
              padding: const EdgeInsets.all(2),
              child: CMImageView(cmSvg.icCheck),
            )
          : Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CMColor.grey4,
              ),
              padding: const EdgeInsets.all(2),
              child: CMImageView(cmSvg.icCheck),
            ),
    );
  }
}

class AppCheckBox3 extends StatefulWidget {
  final bool initialValue;
  final double size, width;
  final ValueChanged<bool>? onChange;
  final bool active;
  final Color? inactiveBbColor;

  const AppCheckBox3({
    super.key,
    this.initialValue = false,
    this.size = 24,
    this.active = true,
    this.onChange,
    this.inactiveBbColor,
    this.width = 1,
  });

  @override
  State<AppCheckBox3> createState() => _AppCheckBoxState3();
}

class _AppCheckBoxState3 extends State<AppCheckBox3> {
  late bool _value;

  double get size => widget.size;

  @override
  void initState() {
    _value = widget.initialValue;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppCheckBox3 oldWidget) {
    if (widget.initialValue != _value) {
      setState(() {
        _value = widget.initialValue;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.active
          ? () {
              setState(() {
                _value = !_value;
                widget.onChange?.call(_value);
              });
            }
          : null,
      child: _value
          ? Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CMColor.primary5,
              ),
              padding: const EdgeInsets.all(2),
              child: CMImageView(cmSvg.icCheck),
            )
          : Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.inactiveBbColor ?? CMColor.greyN3,
                border: Border.all(color: CMColor.grey4, width: widget.width),
              ),
            ),
    );
  }
}
