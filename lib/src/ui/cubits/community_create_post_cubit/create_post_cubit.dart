import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/di.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/common/upload_repository.dart';
import 'package:lh_community/src/utils/cubit_mixin.dart';
import 'package:lh_community/src/utils/event_bus.dart';

part 'create_post_state.dart';

class CMCreatePostCubit extends Cubit<CMCreatePostState> with CubitMixin {
  final List<CMSectionTypeDto> sectionTypes;
  final CMPostTypeDto? postType;
  final CMSectionTypeDto? initSectionType;

  CMCreatePostCubit({
    required this.sectionTypes,
    this.postType,
    this.initSectionType,
  }) : super(CMCreatePostState(selectedType: initSectionType));

  final TextEditingController titleCtl = TextEditingController();
  final TextEditingController contentCtl = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _apiClient = getIt<ApiClient>();

  onChangeType(CMSectionTypeDto type) {
    emit(state.copyWith(selectedType: type));
  }

  onSubmit(List medias) async {
    final fileAtt = await CommunityUploadRepository().uploadMedias(medias);
    final title = titleCtl.text.trim();
    final content = contentCtl.text.trim();
    final data = {
      "postTypeId": postType?.id,
      "sectionTypeId": state.selectedType?.id,
      if ([SectionType.board, SectionType.fileboard]
          .contains(initSectionType?.sectionType))
        "title": title,
      "contents":
          initSectionType?.sectionType == SectionType.gallery ? ' ' : content,
      "files": [...fileAtt.map((x) => x.toJson())],
      "nickname": LHCommunity().nickname,
      "nicknameAvatarUrl": LHCommunity().avatar,
    };
    apiCall(
      showLoading: true,
      callToHost: _apiClient.createPost(data: data),
      success: (data) async {
        LHEventBus.eventBus
            .fire(ReloadSectionTypeEvent(id: state.selectedType?.id ?? -1));
        Navigator.pop(LHCommunity().context);
      },
    );
  }

  @override
  Future<void> close() {
    titleCtl.dispose();
    contentCtl.dispose();
    return super.close();
  }
}
