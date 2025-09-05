part of 'create_post_cubit.dart';

class CMCreatePostState {
  final CMSectionTypeDto? selectedType;

  CMCreatePostState({this.selectedType});

  CMCreatePostState copyWith({
    CMSectionTypeDto? selectedType,
  }) {
    return CMCreatePostState(
      selectedType: selectedType ?? this.selectedType,
    );
  }
}
