import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/model/post_type_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/cubits/community_cubit.dart';
import 'package:lh_community/src/utils/community_avatar.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_dropdown.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/text_style.dart';

class ArtistDropdown extends StatefulWidget {
  const ArtistDropdown({super.key});

  @override
  State<ArtistDropdown> createState() => _ArtistDropdownState();
}

class _ArtistDropdownState extends State<ArtistDropdown> {
  @override
  Widget build(BuildContext context) {
    final favoriteArtist = LHCommunity().postTypePartnerData;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: BlocBuilder<CMPostCubit, CMPostState>(
        buildWhen: (p, c) =>
            p.selectArtist != c.selectArtist || !p.artist.equal(c.artist),
        builder: (context, state) {
          if (state.artist.isNullOrEmpty || state.artist.length == 1) {
            return const SizedBox.shrink();
          }
          return CMDropdown<CMPostTypeDto>(
            initialValue: state.selectArtist,
            onChanged: (value) {
              if (value == null) return;
              context.read<CMPostCubit>().onSelectType(value);
            },
            borderColor: CMColor.grey3,
            itemTitleBuilder: (index) {
              final type = state.artist[index];
              final star = favoriteArtist.firstWhereOrNull(
                  (x) => x.id.toString() == type.projectTypeId);
              return Row(
                spacing: 6,
                children: [
                  CMAvatar(avatar: star?.avatar, size: 24, radius: 8),
                  Text(type.name ?? ''),
                  if (type == state.selectArtist)
                    CMImageView(cmSvg.icCheck,
                        color: CMColor.primary5, size: 16),
                ],
              );
            },
            selectedItemBuilder: (context) {
              return state.artist.map(
                (type) {
                  final star = favoriteArtist.firstWhereOrNull(
                      (x) => x.id.toString() == type.projectTypeId);

                  return Row(
                    spacing: 6,
                    children: [
                      CMAvatar(avatar: star?.avatar, size: 24, radius: 8),
                      Text(
                        type.name ?? '',
                        style: LHTextStyle.message
                            .copyWith(height: 20 / 15, color: CMColor.grey7),
                      ),
                    ],
                  );
                },
              ).toList();
            },
            itemCount: state.artist.length,
            valueGetter: (index) {
              return state.artist[index];
            },
            height: 40,
            dropdownWidth: 120,
            width: 120,
          );
        },
      ),
    );
  }
}
