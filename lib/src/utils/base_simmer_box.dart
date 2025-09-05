import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.child,
  });

  final double? width;
  final double? height;
  final double? radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(radius ?? 0))),
      width: width,
      height: height,
      child: Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: CMColor.primary5.withAlpha(33),
        enabled: true,
        child: child ??
            Container(
              width: width,
              height: height,
              color: CMColor.primary5.withAlpha(33),
            ),
      ),
    );
  }
}
