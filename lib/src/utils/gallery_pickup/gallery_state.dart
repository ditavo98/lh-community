part of 'gallery_cubit.dart';

class SelectImagesState {
  List<Medium> media;
  List<Album> albumList;
  Album? currentAlbum;
  List<Medium> selectedImages;
  bool loadingMore;
  bool loading, isLast;

  SelectImagesState({
    this.media = const [],
    this.currentAlbum,
    this.albumList = const [],
    this.selectedImages = const [],
    this.loadingMore = false,
    this.loading = false,
    this.isLast = false,
  });

  SelectImagesState copyWith({
    List<Medium>? media,
    List<Album>? albumList,
    Album? currentAlbum,
    List<Medium>? selectedImages,
    bool? loadingMore,
    bool? loading,
    bool? isLast,
  }) {
    return SelectImagesState(
      media: media ?? this.media,
      albumList: albumList ?? this.albumList,
      currentAlbum: currentAlbum ?? this.currentAlbum,
      selectedImages: selectedImages ?? this.selectedImages,
      loadingMore: loadingMore ?? this.loadingMore,
      loading: loading ?? this.loading,
      isLast: isLast ?? this.isLast,
    );
  }
}
