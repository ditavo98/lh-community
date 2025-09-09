import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/ui/cubits/community_create_post_cubit/create_post_cubit.dart';
import 'package:lh_community/src/ui/cubits/selected_attachment_cubit/select_att_widget.dart';
import 'package:lh_community/src/ui/cubits/selected_attachment_cubit/selected_attachment_cubit.dart';
import 'package:lh_community/src/utils/community_button.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_form_field.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/community_scaffold.dart';
import 'package:lh_community/src/utils/community_value_listenable_builder.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/dialog_util.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/gallery_pickup/gallery_page.dart';
import 'package:lh_community/src/utils/images.dart';
import 'package:lh_community/src/utils/my_app_bar.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/string_ex.dart';
import 'package:lh_community/src/utils/text_style.dart';
import 'package:photo_gallery/photo_gallery.dart';

class CMCreatePost extends StatefulWidget {
  const CMCreatePost({super.key});

  static Future open(
    BuildContext context, {
    List<CMSectionTypeDto>? postTypes,
    CMSectionTypeDto? initSectionType,
    CMPostTypeDto? initPostType,
  }) {
/*    EventLogManager().logs(
      screen: EventScreenType.fanBoardNew002,
      event: EventType.write_support_post,
    );*/
    return Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CMCreatePostCubit(
              sectionTypes: postTypes ?? [],
              postType: initPostType,
              initSectionType: initSectionType,
            ),
          ),
          BlocProvider(
            create: (context) => SelectedAttachmentCubit(),
          ),
        ],
        child: const CMCreatePost(),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ));
  }

  @override
  State<CMCreatePost> createState() => _CMCreatePostState();
}

class _CMCreatePostState extends State<CMCreatePost> {
  CMCreatePostCubit get _cubit => context.read<CMCreatePostCubit>();

  SelectedAttachmentCubit get _selectedAttCubit =>
      context.read<SelectedAttachmentCubit>();

  SectionType? get _sectionType => _cubit.initSectionType?.sectionType;

  String get _appBarTitle => switch (_sectionType) {
        SectionType.board => cmStr.text_write_support_message,
        SectionType.feed => cmStr.text_create_feed,
        SectionType.gallery => cmStr.text_create_gallery,
        SectionType.fileboard => cmStr.text_write_streaming_post,
        _ => cmStr.text_write_support_message
      };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CMScaffold(
      backgroundColor: CMColor.white,
      appBar: MyAppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
        title: _appBarTitle,
        actions: [_postButton()],
        isBorder: true,
      ),
      autoBodyPaddingImp: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _enter(),
              ),
            ),
            if ([SectionType.feed, SectionType.fileboard]
                .contains(_sectionType)) ...[
              SelectAttWidget(
                onRemove: _selectedAttCubit.onRemove,
                height: 140,
              ),
               Divider(color: CMColor.grey3, height: 1),
              if (_sectionType == SectionType.feed) _pickMedias(),
              if (_sectionType == SectionType.fileboard) _pickImages(),
            ]
          ],
        ),
      ),
    );
  }

  _pickMedias() {
    return InkWell(
      onTap: _onPickMedia,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CMImageView(cmSvg.icImageV3, size: 24),
            const SizedBox(width: 6),
            Text(
              cmStr.text_select_album,
              style: LHTextStyle.subtitle3_1.copyWith(color: CMColor.grey6),
            )
          ],
        ),
      ),
    );
  }

  _onPickMedia() {
    final recordedMedia =
        _selectedAttCubit.state.medias.where((x) => x is! Medium).toList();
    final medias = _selectedAttCubit.state.medias.whereType<Medium>().toList();
    GalleryPage.show(
      context,
      limit: kPostMediaLimit - recordedMedia.length,
      initialChildSize: .4,
      images: medias,
      suffixBuilder: (mediaList, ctx) {
        final enable = mediaList.notNullOrEmpty;
        return AppIconButton(
          onPressed: enable
              ? () async {
                  Future.sync(() => Navigator.pop(ctx));
                  _selectedAttCubit
                      .onSelected([...recordedMedia, ...mediaList]);
                }
              : null,
          child: ClipOval(
            child: ColoredBox(
              color: enable ? CMColor.primary5 : CMColor.grey4,
              child:  Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.arrow_upward,
                  size: 20,
                  weight: 2,
                  color: CMColor.white,
                ),
              ),
            ),
          ),
        );
      },
      onCamera: () async {
        Navigator.pop(context);
        AppDialog.showCupertinoActionSheet(
          context,
          actions: [
            ColoredBox(
              color: Colors.white,
              child: CupertinoActionSheetAction(
                child: Text(
                  cmStr.text_take_a_picture,
                  style:
                      LHTextStyle.button1.copyWith(color: CMColor.primary5),
                ),
                onPressed: () async {
                  Future.sync(() => Navigator.pop(context));
                  final file = await pickImageByCamera();
                  if (file == null) return;
                  ImageGallerySaver.saveFile(file.path);
                  final list = [...medias, File(file.path)];
                  _selectedAttCubit.onSelected(list);
                },
              ),
            ),
            ColoredBox(
              color: Colors.white,
              child: CupertinoActionSheetAction(
                child: Text(
                  cmStr.text_take_a_video,
                  style:
                      LHTextStyle.button1.copyWith(color: CMColor.primary5),
                ),
                onPressed: () async {
                  Future.sync(() => Navigator.pop(context));
                  final file = await pickVideoByCamera();
                  if (file == null) return;
                  ImageGallerySaver.saveFile(file.path);
                  final list = [...medias, File(file.path)];
                  _selectedAttCubit.onSelected(list);
                },
              ),
            ),
          ],
          cancelWidget: Text(cmStr.text_cancel,
              style: LHTextStyle.button1.copyWith(color: CMColor.red9)),
        );
      },
    );
  }

  _pickImages() {
    return AppInkWell(
      onTap: _onPickImages,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CMImageView(cmSvg.icImageV3, size: 24),
            const SizedBox(width: 6),
            Text(
              cmStr.text_add_photo,
              style: LHTextStyle.subtitle3_1.copyWith(color: CMColor.grey6),
            )
          ],
        ),
      ),
    );
  }

  _onPickImages() {
    GalleryPage.show(
      context,
      limit: kPostMediaLimit,
      initialChildSize: .4,
      type: MediumType.image,
      images: _selectedAttCubit.state.medias.whereType<Medium>().toList(),
      suffixBuilder: (mediaList, ctx) {
        final enable = mediaList.notNullOrEmpty;
        return AppIconButton(
          onPressed: enable
              ? () async {
                  Future.sync(() => Navigator.pop(ctx));
                  _selectedAttCubit.onSelected(mediaList);
                }
              : null,
          child: ClipOval(
            child: ColoredBox(
              color: enable ? CMColor.primary5 : CMColor.grey4,
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.arrow_upward,
                  size: 20,
                  weight: 2,
                  color: CMColor.white,
                ),
              ),
            ),
          ),
        );
      },
      onCamera: () async {
        Future.sync(() => Navigator.pop(context));
        final file = await pickImageByCamera();
        if (file == null) return;
        ImageGallerySaver.saveFile(file.path);
        final list = [file];
        _selectedAttCubit.onSelected(list);
      },
    );
  }

  //region app bar actions
  Widget _postButton() {
    return switch (_sectionType) {
      SectionType.board => _postBoardBtn(),
      SectionType.feed => _postFeedBtn(),
      SectionType.gallery => _postGalleryBtn(),
      SectionType.fileboard => _postStreamingBtn(),
      _ => _postBoardBtn()
    };
  }

  Widget _postBtn(bool enable) {
    return TextButton(
      onPressed: enable
          ? () {
              _cubit.onSubmit(_selectedAttCubit.state.medias);
            }
          : null,
      child: Text(
        cmStr.text_post,
        style: LHTextStyle.subtitle2
            .copyWith(color: enable ? CMColor.primary5 : CMColor.grey4),
      ),
    );
  }

  Widget _postBoardBtn() {
    return ValueListenableBuilder2(
      first: _cubit.titleCtl,
      second: _cubit.contentCtl,
      builder: (context, title, content, _) {
        final enable = title.text.notNullOrEmpty && content.text.notNullOrEmpty;
        return _postBtn(enable);
      },
    );
  }

  Widget _postFeedBtn() {
    return ValueListenableBuilder(
      valueListenable: _cubit.contentCtl,
      builder: (context, content, _) {
        final enable = content.text.notNullOrEmpty;
        return _postBtn(enable);
      },
    );
  }

  Widget _postGalleryBtn() {
    return BlocBuilder<SelectedAttachmentCubit, SelectedAttachmentState>(
      builder: (context, state) {
        final enable = state.medias.notNullOrEmpty;
        return _postBtn(enable);
      },
    );
  }

  Widget _postStreamingBtn() {
    return ValueListenableBuilder2(
      first: _cubit.titleCtl,
      second: _cubit.contentCtl,
      builder: (context, title, content, _) {
        return BlocBuilder<SelectedAttachmentCubit, SelectedAttachmentState>(
          builder: (context, state) {
            final enable = title.text.notNullOrEmpty &&
                content.text.notNullOrEmpty &&
                state.medias.notNullOrEmpty;
            return _postBtn(enable);
          },
        );
      },
    );
  }

  //endregion

  //region Enter data
  Widget _enter() {
    return switch (_sectionType) {
      SectionType.board => _supportMessage(),
      SectionType.feed => _feed(),
      SectionType.gallery => _galleryMessage(),
      SectionType.fileboard => _streamingList(),
      _ => _supportMessage()
    };
  }

  Widget _supportMessage() {
    return Form(
      key: _cubit.formKey,
      child: Column(
        children: [
          _title(),
          _descriptions(),
        ],
      ),
    );
  }

  Widget _feed() {
    return CMFormField(
      maxLength: 1000,
      controller: _cubit.contentCtl,
      contentPadding: const EdgeInsets.symmetric(vertical: 11),
      hintText: cmStr.text_share_with_fans,
      hintStyle: LHTextStyle.body1_1.copyWith(color: CMColor.grey5),
      fillColor: CMColor.white,
      textStyle: LHTextStyle.body1_1.copyWith(color: CMColor.grey7),
      maxLines: null,
      inputBorder: InputBorder.none,
      counter: const SizedBox.shrink(),
    );
  }

  Widget _galleryMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cmStr.text_share_artist_photo, style: LHTextStyle.body1_1),
        Dimen.sBHeight8,
        BlocBuilder<SelectedAttachmentCubit, SelectedAttachmentState>(
          builder: (context, state) {
            return SelectAttWidget(
              onRemove: _selectedAttCubit.onRemove,
              height: 140,
              onAdd:
                  state.medias.length >= kPostMediaLimit ? null : _onPickImages,
            );
          },
        ),
      ],
    );
  }

  Widget _streamingList() {
    return Form(
      key: _cubit.formKey,
      child: Column(
        children: [
          _title(),
          _descriptions(),
        ],
      ),
    );
  }

  Widget _title() {
    return CMFormField(
      maxLength: 30,
      inputBorder: InputBorder.none,
      counter: const SizedBox.shrink(),
      contentPadding: const EdgeInsets.symmetric(vertical: 11),
      controller: _cubit.titleCtl,
      hintText: cmStr.text_enter_title2,
      hintStyle: LHTextStyle.subtitle1_1.copyWith(color: CMColor.grey5),
      fillColor: CMColor.white,
      textStyle: LHTextStyle.subtitle1_1,
    );
  }

  Widget _descriptions() {
    return CMFormField(
      maxLength: 1000,
      contentPadding: const EdgeInsets.symmetric(vertical: 11),
      controller: _cubit.contentCtl,
      hintText: _sectionType == SectionType.fileboard
          ? cmStr.text_leave_streaming_proofshot
          : cmStr.text_write_support_message_to_artist,
      hintStyle: LHTextStyle.body1_1.copyWith(color: CMColor.grey5),
      fillColor: CMColor.white,
      textStyle: LHTextStyle.body1_1.copyWith(color: CMColor.grey7),
      maxLines: null,
      inputBorder: InputBorder.none,
      counter: const SizedBox.shrink(),
    );
  }
//endregion
}
