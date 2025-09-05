import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/utils/cubit_mixin.dart';

part 'selected_attachment_state.dart';

class SelectedAttachmentCubit extends Cubit<SelectedAttachmentState>
    with CubitMixin {
  SelectedAttachmentCubit() : super(SelectedAttachmentState());

  onSelected(List medias) {
    emit(SelectedAttachmentState(medias: medias));
  }

  onRemove(media) {
    state.medias.remove(media);
    emit(SelectedAttachmentState(medias: List.from(state.medias)));
  }

  onClear() {
    emit(SelectedAttachmentState());
  }
}
