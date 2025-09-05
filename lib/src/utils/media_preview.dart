import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/widgets/image_view.dart';
import 'package:lh_community/src/ui/widgets/video_view.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_downloader.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/dialog_util.dart';
import 'package:lh_community/src/utils/display_util.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:lh_community/src/utils/text_style.dart';

class MediaPreviewArgument {
  final List? dataList;
  final CommunityPostDto? post;
  final int postType;
  final Widget? currentView;
  final int targetIndex;
  final dynamic target;

  MediaPreviewArgument({
    this.dataList,
    this.post,
    this.postType = 1,
    this.currentView,
    this.targetIndex = 0,
    this.target,
  });
}

class MediaPreview extends StatefulWidget {
  static final routeName = 'mediaPreview';
  final MediaPreviewArgument argument;

  const MediaPreview({super.key, required this.argument});

  static Future navigateMediaPreview(MediaPreviewArgument args) async {
    await LHCommunity().context.pushRouteWithRouteSetting(
          MediaPreview(argument: args),
          settings: RouteSettings(
            name: routeName,
            arguments: args,
          ),
        );
  }

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  final ValueNotifier<int> _pageNotifier = ValueNotifier(0);

  MediaPreviewArgument get arg => widget.argument;

  List get _dataList {
    if (arg.dataList.notNullOrEmpty) {
      return arg.dataList!;
    }
    if (arg.target != null) {
      return [arg.target];
    }
    return [];
  }

  int get _itemCount {
    return _dataList.length ?? 0;
  }

  CommunityPostDto? get post => arg.post;

  int get postType => arg.postType;

  int get _targetIndex {
    if (arg.target != null) {
      return _dataList.indexOf(arg.target);
    }

    return arg.targetIndex;
  }

  Widget? get currentView => widget.argument.currentView;
  late PageController _pageController;

  @override
  void initState() {
    if (_targetIndex > 0) {
      _pageController = PageController(initialPage: _targetIndex);
      _pageNotifier.value = _targetIndex;
    } else {
      _pageController = PageController(initialPage: 0);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DismissiblePage(
        onDismissed: () {
          Navigator.of(context).pop();
        },
        isFullScreen: true,
        minRadius: 0,
        maxRadius: 150,
        direction: DismissiblePageDismissDirection.vertical,
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  _pageNotifier.value = page;
                },
                itemCount: _itemCount,
                itemBuilder: (crx, index) {
                  var item = _dataList.getOrNull(index);
                  if (index == _targetIndex && currentView != null) {
                    return currentView!;
                  }
                  var isVideo = false;
                  var isImage = false;
                  if (item is CommunityFileElementDto) {
                    var i = item;
                    isVideo = i.type == 'video';
                    isImage = i.type == 'image';
                  }

                  if (isVideo) {
                    return CMFeedVideoView(
                      file: item,
                      files: _dataList,
                      post: post,
                      postType: postType,
                      aspectRatio: 1,
                      isViewFull: true,
                    );
                  }
                  if (isImage) {
                    return CMFeedImageView(
                      file: item,
                      files: _dataList,
                      post: post,
                      postType: postType,
                      aspectRatio: 1,
                      inPreview: true,
                    );
                  }
                },
              ),
              SizedBox(
                height: 100,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        final file = _dataList.getOrNull(_pageNotifier.value);
                        if (file is! CommunityFileElementDto ||
                            file.url.isNullOrEmpty) {
                          AppDialog.showFailedToast(
                              msg: str.error_something_went_wrong_try_again);
                          return;
                        }
                        CMDownloader().downloadFile(urlLink: file.url!);
                      },
                      icon: CMImageView(
                        cmSvg.icDownload3,
                        color: CMColor.white,
                      ),
                    )
                  ],
                  titleSpacing: 0,
                  centerTitle: true,
                  title: _pageText(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageText() {
    if (_dataList.length <= 1) {
      return SizedBox();
    }
    return ValueListenableBuilder<int>(
      valueListenable: _pageNotifier,
      builder: (context, value, _) {
        return Center(
          child: Text(
            '${value + 1}/${_dataList.length}',
            style: LHTextStyle.body3.copyWith(color: Colors.white, height: 1.5),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }
}
