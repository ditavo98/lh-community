part of 'selected_attachment_cubit.dart';

class SelectedAttachmentState {
  final List medias;

  SelectedAttachmentState({this.medias = const []});

  SelectedAttachmentState copyWith({
    List? medias,
  }) {
    return SelectedAttachmentState(
      medias: medias ?? this.medias,
    );
  }
}
