import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';

class CMAvatar extends StatelessWidget {
  final dynamic avatar;
  final double size, radius;
  final Function()? onTap;

  const CMAvatar({
    super.key,
    required this.avatar,
    this.size = 40,
    this.radius = 12,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: Border.all(
          color: CMColor.black.withValues(alpha: .04),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: CMImageView(
          key: ValueKey(avatar),
          avatar,
          size: size,
          fit: BoxFit.cover,
          radius: radius,
          onTap: onTap,
        ),
      ),
    );
  }
}
