import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/cubit_mixin.dart';
import 'package:lh_community/src/utils/dialog_util.dart';
import 'package:lh_community/src/utils/native_utils.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';

part 'gallery_state.dart';

const int kImageLimit = 10;

class SelectImagesCubit extends Cubit<SelectImagesState> with CubitMixin {
  final MediumType? type;
  final int limit;
  List<Medium> images;

  SelectImagesCubit({
    this.type = MediumType.image,
    this.limit = kImageLimit,
    this.images = const [],
  }) : super(SelectImagesState(selectedImages: images));
  late MediaPage _imagePage;

  bool get _isSingleImage => limit == 1;

  Future getImageAndAlbum() async {
    var imageAlbums = await PhotoGallery.listAlbums(mediumType: type);
    if (imageAlbums.isNullOrEmpty) return;
    var currentAlbum = imageAlbums.first;
    _imagePage = await currentAlbum.listMedia(take: 50);
    var media = _filterAlbumList(_imagePage.items);
    emit(
      state.copyWith(
        media: media,
        currentAlbum: currentAlbum,
        albumList: imageAlbums,
        loading: false,
        isLast: _imagePage.isLast,
      ),
    );
  }

  Future loadMoreMedia() async {
    if (_imagePage.isLast) return;
    emit(state.copyWith(loadingMore: true));
    var medias = List<Medium>.from(state.media);
    _imagePage = await _imagePage.nextPage();
    var newMedia = _filterAlbumList(_imagePage.items);
    medias.addAll(newMedia);
    emit(state.copyWith(
      media: medias,
      loadingMore: false,
      isLast: _imagePage.isLast,
    ));
  }

  Future changeAlbum(Album selectedAlbum) async {
    var currentAlbum =
        state.albumList.firstWhere((x) => x.id == selectedAlbum.id);
    _imagePage = await currentAlbum.listMedia();
    var media = _filterAlbumList(_imagePage.items);
    emit(
      SelectImagesState(
          media: media,
          currentAlbum: currentAlbum,
          albumList: state.albumList,
          selectedImages: state.selectedImages),
    );
  }

  void selectedImage(Medium selectedImage) async {
    // var file = await selectedImage.getFile();
    if (selectedImage.mediumType == MediumType.video) {
      if ((selectedImage.size ?? 0) > 52428800) {
        AppDialog.showFailedToast(
            msg: str.text_max_file_size(50));
        return;
      }
    }
    if (_isSingleImage) {
      emit(state.copyWith(selectedImages: [selectedImage]));
      return;
    }
    var imagesSelected = List<Medium>.from(state.selectedImages);
    var isExist = imagesSelected.contains(selectedImage);
    if (isExist) {
      imagesSelected.remove(selectedImage);
    } else {
      if (state.selectedImages.length == limit) {
        AppDialog.showFailedToast(msg: str.maximumImage(limit));
        return;
      }
      imagesSelected.add(selectedImage);
    }
    emit(state.copyWith(selectedImages: imagesSelected));
  }

  void onResetData() {
    emit(SelectImagesState(
      media: state.media,
      currentAlbum: state.currentAlbum,
      albumList: state.albumList,
    ));
  }

  List<Medium> _filterAlbumList(List<Medium> medias) {
    return medias.where((element) {
      if (element.mediumType == MediumType.video) {
        return true;
      }
      return element.mimeType != "image/heic";
    }).toList();
  }

  Future<PermissionStatus> _statusOfPhotoOrStoragePermission() async {
    if (Platform.isAndroid && (await NativeUtil.isAndroidSDK32OrLower())) {
      return await Permission.storage.status;
    }
    return await Permission.photos.status;
  }

  Future<PermissionStatus> _requestPhotoOrStoragePermission() async {
    if (Platform.isAndroid && (await NativeUtil.isAndroidSDK32OrLower())) {
      return await Permission.storage.request();
    }
    return await Permission.photos.request();
  }

  Future<bool> promptPermissionSetting() async {
    late PermissionStatus photoOrStorage;
    photoOrStorage = await _statusOfPhotoOrStoragePermission();

    // var manageExternalStoragePermission =
    //     await Permission.manageExternalStorage.status;
    if (!photoOrStorage.isGranted) {
      await _requestPhotoOrStoragePermission();
    }
    // if (!manageExternalStoragePermission.isGranted) {
    //   await Permission.manageExternalStorage.request();
    // }

    photoOrStorage = await _statusOfPhotoOrStoragePermission();
    // manageExternalStoragePermission =
    //     await Permission.manageExternalStorage.status;

    if (Platform.isIOS) {
      if (photoOrStorage.isPermanentlyDenied || photoOrStorage.isDenied) {
        await AppDialog.alertMediaPermission(LHCommunity().context);
      }
      return photoOrStorage.isGranted || photoOrStorage.isLimited;
    } else {
      if (photoOrStorage.isPermanentlyDenied ||
              // manageExternalStoragePermission.isPermanentlyDenied ||
              photoOrStorage.isDenied
          // || manageExternalStoragePermission.isDenied
          ) {
        await AppDialog.alertMediaPermission(LHCommunity().context);
      }
      return (photoOrStorage.isGranted || photoOrStorage.isLimited)
          /*&& (manageExternalStoragePermission.isGranted ||
              manageExternalStoragePermission.isRestricted)*/
          ;
    }
  }
}
