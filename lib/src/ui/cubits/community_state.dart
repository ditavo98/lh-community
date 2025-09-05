part of 'community_cubit.dart';

class CMPostState {
  final bool initial;
  final List<CMPostTypeDto> artist;
  final CMPostTypeDto? selectArtist;
  final List<CMSectionTypeDto> sectionTypes;
  final CMSectionTypeDto? selectSection;

  CMPostState({
    this.initial = true,
    this.artist = const [],
    this.selectArtist,
    this.sectionTypes = const [],
    this.selectSection,
  });

  CMPostState copyWith({
    bool? initial,
    List<CMPostTypeDto>? artist,
    CMPostTypeDto? selectArtist,
    List<CMSectionTypeDto>? sectionTypes,
    CMSectionTypeDto? selectSection,
  }) {
    return CMPostState(
      initial: initial ?? this.initial,
      artist: artist ?? this.artist,
      selectArtist: selectArtist ?? this.selectArtist,
      sectionTypes: sectionTypes ?? this.sectionTypes,
      selectSection: selectSection ?? this.selectSection,
    );
  }
}
