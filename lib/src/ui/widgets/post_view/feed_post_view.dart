part of 'post_view.dart';

class CMFeedPostView extends StatelessWidget {
  final CommunityPostDto post;

  final bool isDetail;

  const CMFeedPostView({super.key, required this.post}) : isDetail = false;

  const CMFeedPostView.detail({super.key, required this.post}) : isDetail = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isDetail ? EdgeInsets.zero : const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          if ((post.contents?.trim()).notNullOrEmpty) ...[
            Dimen.sBHeight4,
            CMReadMoreText(
              post.contents ?? '',
              trimLines: 10,
              trimMode: TrimMode.line,
              style: LHTextStyle.body1_1
                  .copyWith(color: CMColor.grey7, height: 1.4),
              colorClickableText: CMColor.primary5,
              trimCollapsedText: '...${cmStr.text_read_more}',
              trimExpandedText: cmStr.text_read_less,
            ),
          ],
          _postView(),
          CMPostInteracts.feed(post: post),
        ],
      ),
    );
  }

  _postView() {
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
    if (post.files!.length > 1 || post.files?.firstOrNull?.type == 'video') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: AspectRatio(
          aspectRatio: 1,
          child: CMFeedMediaView(post: post, borderRadius: 8),
        ),
      );
    }
    final file = post.files!.first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ConstrainedBox(
        constraints: isDetail
            ? const BoxConstraints()
            : BoxConstraints(maxHeight: Dimen.isTablet ? 780 : 440),
        child: (file.type == 'video')
            ? CMFeedVideoView(
                file: file,
                files: post.files!,
                post: post,
                aspectRatio: file.displayRatio ?? 1,
                borderRadius: 8,
              )
            : CMFeedImageView.single(
                file: file,
                files: post.files!,
                post: post,
                borderRadius: 8,
              ),
      ),
    );
  }

  _header() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              CMAvatar(avatar: post.postAuthorAvatar, size: 28),
              const SizedBox(width: 6),
              Text(
                post.postAuthorName ?? '',
                style: LHTextStyle.subtitle3_1.copyWith(height: 1.7),
              ),
              Container(
                width: 3,
                height: 3,
                decoration:  BoxDecoration(
                  color: CMColor.greyN4,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              Text(
                post.postedAt.timeAgo(),
                style: LHTextStyle.body3
                    .copyWith(height: 1.7, color: CMColor.grey6),
              ),
            ],
          ),
        ),
        if (!isDetail)
          Builder(builder: (context) {
            return CMMoreButton(
              id: post.id ?? -1,
              artist: context.read<CMArtistPostCubit>().artistUser,
              communityUser: post.user,
            );
          }),
      ],
    );
  }
}
