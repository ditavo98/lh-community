// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/utils/community_button.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/dialog_util.dart';
import 'package:lh_community/src/utils/gallery_pickup/gallery_cubit.dart';
import 'package:lh_community/src/utils/loadmore_widget.dart';
import 'package:lh_community/src/utils/map_ex.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/text_style.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPage extends StatefulWidget {
  final ScrollController? scrollController;
  final Widget Function(List<Medium> media, BuildContext context)?
      suffixBuilder;
  final bool includeCamera;
  final VoidCallback? onCamera;
  final bool isWidgetView;
  final Widget Function(BuildContext context, Medium medium)? itemBuilder;

  const GalleryPage({
    super.key,
    this.scrollController,
    this.suffixBuilder,
    this.includeCamera = false,
    this.onCamera,
  })  : isWidgetView = false,
        itemBuilder = null;

  const GalleryPage.widget({
    super.key,
    this.includeCamera = false,
    this.onCamera,
    this.itemBuilder,
  })  : scrollController = null,
        suffixBuilder = null,
        isWidgetView = true;

  static Future show(
    BuildContext context, {
    final MediumType? type,
    int limit = kImageLimit,
    List<Medium> images = const [],
    double initialChildSize = 0.7,
    Widget Function(List<Medium> media, BuildContext context)? suffixBuilder,
    bool includeCamera = false,
    VoidCallback? onCamera,
  }) async {
    return AppDialog.showModalBottomDrag(
      context,
      initialChildSize: initialChildSize,
      builder: (context, ctl) {
        return BlocProvider(
          create: (context) => SelectImagesCubit(
            type: type,
            limit: limit,
            images: images,
          ),
          child: GalleryPage(
            scrollController: ctl,
            suffixBuilder: suffixBuilder,
            includeCamera: includeCamera,
            onCamera: onCamera,
          ),
        );
      },
    );
  }

  static Future askToShow(
    BuildContext context, {
    final MediumType? type,
    int limit = kImageLimit,
    List<Medium> images = const [],
    List<Widget>? actions,
  }) async {
    final result = await AppDialog.showCupertinoActionSheet(
      context,
      actions: actions,
      cancelWidget: Text(cmStr.text_close,
          style: LHTextStyle.button1.copyWith(color: CMColor.primary5)),
    );
    if (result != true) return;
    return AppDialog.showModalBottomDrag(
      context,
      builder: (context, ctl) {
        return BlocProvider(
          create: (context) => SelectImagesCubit(
            type: type,
            limit: limit,
            images: images,
          ),
          child: GalleryPage(scrollController: ctl),
        );
      },
    );
  }

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with SingleTickerProviderStateMixin {
  var expandView = ValueNotifier<bool>(false);
  late ValueNotifier<PermissionState?> _photoPermission;

  SelectImagesCubit get _cubit => context.read<SelectImagesCubit>();

  @override
  void initState() {
    _photoPermission = ValueNotifier(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getImageAndAlbum();
    });
    _checkPermission();
    super.initState();
  }

  _checkPermission() async {
    _photoPermission.value = await PhotoManager.requestPermissionExtend();
    PhotoManager.addChangeCallback(_photoCallBack);
    PhotoManager.startChangeNotify();
  }

  _photoCallBack(MethodCall event) {
    final arg = event.arguments as Map?;
    final newCount = arg.getInt('newCount');
    final oldCount = arg.getInt('oldCount');
    if (_photoPermission.value == PermissionState.limited ||
        (newCount != oldCount)) {
      _cubit.getImageAndAlbum();
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    expandView.dispose();
    _photoPermission.dispose();
    PhotoManager.removeChangeCallback(_photoCallBack);
    PhotoManager.stopChangeNotify();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header(),
        Expanded(
          child: _permissionCheck(
            child: BlocBuilder<SelectImagesCubit, SelectImagesState>(
              builder: (context, state) {
                if (state.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.media.isNullOrEmpty) {
                  return const SizedBox.shrink();
                }
                return LoadMore(
                  onLoadMore: () async {
                    _cubit.loadMoreMedia();
                    return true;
                  },
                  isFinish: state.isLast,
                  child: GridView.builder(
                    controller: widget.scrollController,
                    itemCount:
                        state.media.length + (widget.includeCamera ? 2 : 1),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 124,
                      mainAxisSpacing: 2.0,
                      crossAxisSpacing: 2.0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0 && widget.includeCamera) {
                        return InkWell(
                          onTap: widget.onCamera,
                          child: ColoredBox(
                            color: CMColor.grey5,
                            child: SizedBox.square(
                              dimension: 20,
                              child: CMImageView(
                                cmSvg.icCamera2,
                                size: 20,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        );
                      }
                      if (index == _getLength(state)) {
                        return state.loadingMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      } else {
                        var curIndex = index;
                        if (widget.includeCamera) {
                          curIndex -= 1;
                        }
                        var medium = state.media[curIndex];
                        if (widget.itemBuilder != null) {
                          return widget.itemBuilder!(context, medium);
                        }
                        return _itemBuilder(medium, state);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemBuilder(Medium medium, SelectImagesState state) {
    bool isSelected = state.selectedImages.contains(medium);
    return GestureDetector(
      onTap: () {
        context.read<SelectImagesCubit>().selectedImage(medium);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FadeInImage(
            fit: BoxFit.cover,
            placeholder: MemoryImage(kTransparentImage),
            image: ThumbnailProvider(
              mediumId: medium.id,
              mediumType: medium.mediumType,
              highQuality: true,
            ),
          ),
          if (medium.mediumType == MediumType.video)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.72),
                ),
                child: Text(
                  formattedTime(milliseconds: medium.duration),
                  style: LHTextStyle.h3
                      .copyWith(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: CMColor.primary5, width: 2),
              ),
            ),
          Positioned(
            right: 7,
            top: 7,
            child: Container(
              height: 18,
              width: 18,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? const Border()
                      : Border.all(width: 2, color: CMColor.white),
                  color: isSelected ? CMColor.primary5 : Colors.transparent),
              child: isSelected
                  ? Center(
                      child: Text(
                        '${state.selectedImages.indexOf(medium) + 1}',
                        style: LHTextStyle.subtitle5
                            .copyWith(color: CMColor.white),
                      ),
                    )
                  : null,
            ),
          )
        ],
      ),
    );
  }

  Widget _header() {
    if (widget.isWidgetView) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<SelectImagesCubit, SelectImagesState>(
          builder: (context, state) {
            return Container(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 24,
                    ),
                  ),
                  Flexible(
                    child: DropdownButton<Album>(
                      value: state.currentAlbum,
                      underline: Container(
                        height: 0,
                        color: CMColor.white,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: state.albumList.map((Album album) {
                        return DropdownMenuItem<Album>(
                          value: album,
                          child: Text(
                            album.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: LHTextStyle.button1,
                          ),
                        );
                      }).toList(),
                      onChanged: (album) {
                        if (album != null) {
                          _cubit.changeAlbum(album);
                        }
                      },
                    ),
                  ),
                  Row(children: [_suffix(state)]),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  int _getLength(SelectImagesState state) {
    var length = state.media.length;
    if (widget.includeCamera) {
      length += 1;
    }
    return length;
  }

  Widget _suffix(SelectImagesState state) {
    if (widget.suffixBuilder != null) {
      return widget.suffixBuilder!.call(state.selectedImages, context);
    }
    return Visibility(
      visible: state.selectedImages.notNullOrEmpty,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(state.selectedImages);
        },
        child: Text(cmStr.text_check, style: LHTextStyle.button1),
      ),
    );
  }

  formattedTime({required int milliseconds}) {
    Duration duration = Duration(milliseconds: milliseconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _permissionCheck({required Widget child}) {
    return ValueListenableBuilder(
      valueListenable: _photoPermission,
      builder: (context, permission, _) {
        if (permission == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (permission == PermissionState.denied) {
          return Center(
            child: CMAppButton(
              onTap: PhotoManager.openSetting,
              text: cmStr.go_to_setting,
              isExpand: false,
              radius: 40,
            ),
          );
        }
        return child;
      },
    );
  }
}
