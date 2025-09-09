import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/model/post_dto.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/common/post_type_partner_data.dart';
import 'package:lh_community/src/ui/common/report/community_repo.dart';
import 'package:lh_community/src/ui/common/report/report_dialog.dart';
import 'package:lh_community/src/ui/cubits/community_modify_post_cubit/community_modify_post_cubit.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/community_image.dart';
import 'package:lh_community/src/utils/dialog_util.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/text_style.dart';

class CMMoreButton extends StatelessWidget {
  final int id;
  final LHUserDto? communityUser;
  final ReportTarget reportTarget;
  final VoidCallback? onReported;
  final VoidCallback? onBlocked;
  final VoidCallback? onDeletePostCallback;
  final CMPostTypePartnerData? artist;
  final int postId;
  final int? parentId;
  final int? repliesCount;

  const CMMoreButton({
    super.key,
    required this.id,
    this.reportTarget = ReportTarget.post,
    this.onReported,
    this.artist,
    this.onBlocked,
    required this.communityUser,
    this.onDeletePostCallback,
  })  : postId = id,
        parentId = null,
        repliesCount = null;

  const CMMoreButton.comment({
    super.key,
    required this.id,
    this.reportTarget = ReportTarget.comment,
    this.onReported,
    this.onBlocked,
    required this.communityUser,
    required this.postId,
    this.parentId,
    this.repliesCount,
  })  : artist = null,
        onDeletePostCallback = null;

  bool get isMy => communityUser?.projectUserId == LHCommunity().userId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppDialog.showCupertinoActionSheet(
          context,
          cancelWidget: Text(cmStr.text_cancel, style: LHTextStyle.body2),
          actions: _actions(context),
        );
      },
      child: Icon(
        Icons.more_vert,
        color: CMColor.grey6,
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    if (isMy) {
      return [
        ColoredBox(
          color: Colors.white,
          child: CupertinoActionSheetAction(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CMImageView(cmSvg.icDelete, size: 24, color: CMColor.grey7),
                Dimen.sBWidth8,
                Text(
                  cmStr.text_delete,
                  style: LHTextStyle.button1.copyWith(color: CMColor.grey7),
                ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              _onDelete(context);
            },
          ),
        ),
      ];
    }
    return [
      ColoredBox(
        color: Colors.white,
        child: CupertinoActionSheetAction(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CMImageView(
                cmSvg.icReport,
                color: CMColor.red9,
                size: 24,
              ),
              Dimen.sBWidth8,
              Text(
                cmStr.text_report,
                style: LHTextStyle.button1.copyWith(color: CMColor.red9),
              ),
            ],
          ),
          onPressed: () async {
            Navigator.of(context).pop(true);
            var result = await ReportDialog.show(reportTarget, id);
            if (result == true) {
              var cubit = LHCommunity().context.read<CMModifyPostCubit>();
              cubit.onReportPost(postId: id);
              onReported?.call();
            }
          },
        ),
      ),
      ColoredBox(
        color: Colors.white,
        child: CupertinoActionSheetAction(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CMImageView(
                cmSvg.icBlock,
                color: CMColor.red9,
                size: 24,
              ),
              Dimen.sBWidth8,
              Text(
                cmStr.text_hide,
                style: LHTextStyle.button1.copyWith(color: CMColor.red9),
              ),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop(true);
            _onBlock(context);
          },
        ),
      ),
    ];
  }

  _onBlock(BuildContext context) async {
    AppDialog.showAlertDialog(
      title: cmStr.text_confirm_hide_all_posts_by_author,
      cancelText: cmStr.text_cancel,
      acceptedCallback: () async {
        Navigator.of(context).pop();
        final id = communityUser?.id ?? -1;
        final projectUserId = communityUser?.projectUserId ?? '-1';
        final blocked = await ReportRepo().block(userId: projectUserId);
        if (blocked) {
          var cubit = context.read<CMModifyPostCubit>();
          cubit.onBlockPost(userId: id);
          onBlocked?.call();
        } else {
          AppDialog.showFailedToast(
              msg: cmStr.error_something_went_wrong_try_again);
        }
      },
    );
  }

  _onDelete(BuildContext context) async {
    if (reportTarget == ReportTarget.user) return;
    AppDialog.showAlertDialog(
      title: cmStr.text_confirm_delete_post,
      cancelText: cmStr.text_cancel,
      acceptedCallback: () async {
        Navigator.of(context).pop();
        bool deleted = false;
        if (reportTarget == ReportTarget.post) {
          deleted = await ReportRepo().deletePost(postId: id);
        }
        if (reportTarget == ReportTarget.comment) {
          deleted = await ReportRepo().deleteComment(commentId: id);
        }
        if (deleted) {
          var cubit = context.read<CMModifyPostCubit>();
          if (reportTarget == ReportTarget.post) {
            cubit.onDeletePost(postId: id);
            onDeletePostCallback?.call();
          }
          if (reportTarget == ReportTarget.comment) {
            cubit.onDeleteComment(
              postId: postId,
              commentId: id,
              parentId: parentId,
              replyCount: repliesCount,
            );
          }
        } else {
          AppDialog.showFailedToast(
              msg: cmStr.error_something_went_wrong_try_again);
        }
      },
    );
  }
}
