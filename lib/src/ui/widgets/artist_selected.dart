import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/cubits/community_cubit.dart';
import 'package:lh_community/src/utils/community_avatar.dart';
import 'package:lh_community/src/utils/community_button.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/community_scaffold.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/display_util.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/text_style.dart';

class ArtistSelected extends StatelessWidget {
  const ArtistSelected({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CMPostCubit, CMPostState>(
      buildWhen: (p, c) =>
          p.selectArtist != c.selectArtist || !p.artist.equal(c.artist),
      builder: (context, state) {
        if (state.artist.isNullOrEmpty || state.artist.length == 1) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () {
              context.pushTransparentRouteWithRouteSetting(_SelectPostType(
                artist: state.artist,
                selectThePostType: (type) {
                  context.read<CMPostCubit>().onSelectType(type);
                },
              ));
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                  // border: Border.all(color: LHColor.grey3),
                  // borderRadius: const BorderRadius.all(Dimen.radius8),
                  ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  children: [
                    Text(state.selectArtist!.name ?? '',
                        style: LHTextStyle.body3),
                    Dimen.sBWidth4,
                    CMImageView(
                      cmSvg.icArrowDown,
                      fit: BoxFit.scaleDown,
                      size: 16,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SelectPostType extends StatelessWidget {
  final List<CMPostTypeDto> artist;
  final ValueSetter<CMPostTypeDto> selectThePostType;

  const _SelectPostType(
      {super.key, required this.artist, required this.selectThePostType});

  @override
  Widget build(BuildContext context) {
    return CMScaffold(
      backgroundColor: CMColor.black.withValues(alpha: .45),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              color: CMColor.white,
              borderRadius: BorderRadius.all(Dimen.radius16)),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Text(str.artists,
                  style: LHTextStyle.h4.copyWith(height: 32 / 20)),
              Wrap(
                spacing: 12,
                children: [...artist.map((star) => _artistItem(context, star))],
              ),
              Dimen.sBHeight16,
              CMAppButton(
                onTap: () {
                  Navigator.pop(context);
                },
                text: str.text_close,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _artistItem(BuildContext context, CMPostTypeDto type) {
    final favoriteArtist = LHCommunity().postTypePartnerData;
    final star = favoriteArtist
        .firstWhereOrNull((x) => x.id.toString() == type.projectTypeId);
    if (star == null) return const SizedBox.shrink();
    return AppInkWell(
      onTap: () {
        selectThePostType(type);
        Navigator.pop(context);
      },
      child: Column(
        children: [
          CMAvatar(
            key: ValueKey(star.id),
            avatar: star.avatar,
            size: Dimen.isTablet ? 104 : 80,
            radius: Dimen.isTablet ? 40 : 30,
          ),
          Dimen.sBHeight4,
          Text(
            star.nickname ?? '',
            style: LHTextStyle.time.copyWith(color: CMColor.grey7),
          )
        ],
      ),
    );
  }
}
