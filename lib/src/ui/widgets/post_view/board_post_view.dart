part of 'post_view.dart';

class CMBoardPostView extends StatelessWidget {
  final CommunityPostDto post;

  final bool isDetail;

  const CMBoardPostView({super.key, required this.post}) : isDetail = false;

  const CMBoardPostView.detail({super.key, required this.post}) : isDetail = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isDetail
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _content()),
                    if (!isDetail)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: _attachmentView(),
                      ),
                  ],
                ),
                if (isDetail) _attachmentView(),
                const SizedBox(height: 10),
                CMPostInteracts(post: post),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(post.title ?? '', style: LHTextStyle.message17),
        if (isDetail)
          CMReadMoreText(
            post.contents ?? '',
            trimLines: 10,
            trimMode: TrimMode.line,
            style:
                LHTextStyle.body1.copyWith(color: CMColor.grey6, height: 1.4),
            colorClickableText: CMColor.primary5,
            trimCollapsedText: '...${cmStr.text_read_more}',
            trimExpandedText: cmStr.text_read_less,
          )
        else
          Text(
            post.contents ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                LHTextStyle.body1.copyWith(color: CMColor.grey6, height: 1.4),
          ),
      ],
    );
  }

  Widget _attachmentView() {
    if (post.files.isNullOrEmpty) return const SizedBox.shrink();
    if (isDetail) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: CMFeedMediaView(
          post: post,
          borderRadius: 8,
          isDetail: isDetail,
        ),
      );
    }
    return ClipRRect(
      borderRadius: const BorderRadius.all(Dimen.radius8),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          children: [
            CMImageView(
              post.files!.first.thumbnailUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            if (post.files!.length > 1)
              Positioned(
                bottom: 4,
                right: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: CMColor.black.withValues(alpha: 60),
                    borderRadius: const BorderRadius.all(Dimen.radius8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.5),
                    child: Text(
                      post.files!.length.toString(),
                      style: LHTextStyle.subtitle5
                          .copyWith(color: CMColor.white),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
