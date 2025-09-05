import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/ui/cubits/selected_attachment_cubit/selected_attachment_cubit.dart';
import 'package:lh_community/src/utils/community_button.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/lh_utils.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:lh_community/src/utils/text_style.dart';
import 'package:photo_gallery/photo_gallery.dart';

class SelectAttWidget extends StatelessWidget {
  final ValueSetter<dynamic> onRemove;
  final double height;
  final VoidCallback? onAdd;

  const SelectAttWidget({
    super.key,
    required this.onRemove,
    this.height = 72,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return _selectedMedias();
  }

  Widget _selectedMedias() {
    return BlocBuilder<SelectedAttachmentCubit, SelectedAttachmentState>(
      builder: (context, state) {
        if (state.medias.isNullOrEmpty && onAdd == null) {
          return const SizedBox.shrink();
        }
        int length = state.medias.length;
        if (onAdd != null) length++;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            height: height,
            child: ListView.separated(
              padding: onAdd != null
                  ? null
                  : const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                if (index == length - 1 && onAdd != null) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.all(Dimen.radius8),
                    child: AppInkWell(
                      onTap: onAdd,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ColoredBox(
                          color: CMColor.grey2,
                          child: SizedBox.expand(
                            child: Center(
                              child: Icon(Icons.add,
                                  size: 24, color: CMColor.grey5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return _localAttItem(state.medias[index]);
              },
              separatorBuilder: (_, __) => Dimen.sBWidth8,
              itemCount: length,
            ),
          ),
        );
      },
    );
  }

  Widget _localAttItem(dynamic media) {
    bool isVideo = false;
    bool isImage = false;
    Widget? widget;
    if (media is File) {
      isVideo = media.path.isVideo;
      isImage = media.path.isImage;
      if (isVideo) {
        widget = AspectRatio(
          aspectRatio: 1,
          child: FutureBuilder<File?>(
            future: LHUtils.generateThumbnail(media),
            builder: (context, snapshot) {
              final fileData = snapshot.data;
              if (fileData != null) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Image.file(
                        fileData,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        );
      } else if (isImage) {
        widget = Image.file(
          media,
          fit: BoxFit.cover,
        );
      }
    }
    if (media is Medium) {
      isVideo = media.mediumType == MediumType.video;
      isImage = media.mediumType == MediumType.image;
      widget = Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: MemoryImage(kTransparentImage),
              image: ThumbnailProvider(
                mediumId: media.id,
                mediumType: media.mediumType,
                highQuality: true,
              ),
            ),
          ),
          if (isVideo)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          if (isVideo)
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.72),
                ),
                child: Text(
                  LHUtils.formattedTime(milliseconds: media.duration),
                  style: LHTextStyle.body4
                      .copyWith(height: 1.2, color: Colors.white),
                ),
              ),
            ),
        ],
      );
    }
    if (widget == null) return const SizedBox.shrink();
    return Stack(
      children: [
        ClipRRect(
            borderRadius: const BorderRadius.all(Dimen.radius8), child: widget),
        Positioned(
          right: 4,
          top: 4,
          child: AppInkWell(
            onTap: () {
              onRemove.call(media);
            },
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: CMColor.grey7,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.close,
                size: 12,
                weight: 1.5,
                color: CMColor.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
