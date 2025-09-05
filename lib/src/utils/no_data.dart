import 'package:flutter/material.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/text_style.dart';

class NoData extends StatelessWidget {
  final VoidCallback? onRefresh;

  final String? text;
  final GlobalKey<RefreshIndicatorState>? keyRefresh;

  const NoData({super.key, this.onRefresh, this.keyRefresh, this.text});

  @override
  Widget build(BuildContext context) {
    return onRefresh != null
        ? _buildNoDataRefresh(context)
        : _buildNoData(context);
  }

  Widget _buildNoDataRefresh(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh?.call();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: constraints,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // AppImageView(
                      //   appImg.emptyData,
                      //   height: 132,
                      //   width: 132,
                      // ),
                      // const SizedBox(height: 8),
                      Text(
                        text ?? '',
                        textAlign: TextAlign.center,
                        style:
                            LHTextStyle.body3.copyWith(color: CMColor.grey5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNoData(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      /*    AppImageView(
            appImg.emptyData,
            height: 132,
            width: 132,
          ),*/
          if (text?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                text ?? '',
                textAlign: TextAlign.center,
                style: LHTextStyle.body3.copyWith(color: CMColor.grey5),
              ),
            ),
        ],
      ),
    );
  }
}
