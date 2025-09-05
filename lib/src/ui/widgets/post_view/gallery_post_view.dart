part of 'post_view.dart';

class CMGalleryPostView extends StatelessWidget {
  final CommunityPostDto post;

  const CMGalleryPostView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CMImageView(
            post.files?.firstOrNull?.thumbnailUrl,
            fit: BoxFit.cover,
          ),
        ),
        Align(alignment: Alignment.bottomLeft, child: _data())
      ],
    );
  }

  Widget _data() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: CMImageView(
                  key: ValueKey(post.isLiked),
                  post.isLiked == true ? cmSvg.icHeart16Fill : cmSvg.icHeart16,
                  size: Dimen.isTablet ? 20 : 14,
                  color: post.isLiked == true ? null : CMColor.white,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                LHUtils.getShortValue(post.likeCount.value),
                style: LHTextStyle.message11.copyWith(
                    color: CMColor.white,
                    height: Dimen.isTablet ? (24 / 16) : (19 / 11),
                    fontSize: Dimen.isTablet ? 16 : 11),
              )
            ],
          ),
          if ((post.files?.length).value > 1)
            Container(
              decoration: BoxDecoration(
                color: CMColor.black.withValues(alpha: .6),
                borderRadius: const BorderRadius.all(Dimen.radius8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6.5),
              child: Text(
                post.files!.length.toString(),
                style: LHTextStyle.subtitle5.copyWith(
                  color: CMColor.white,
                  fontSize: Dimen.isTablet ? 14 : 10,
                  height: Dimen.isTablet ? 1.45 : null,
                ),
              ),
            )
        ],
      ),
    );
  }
}
