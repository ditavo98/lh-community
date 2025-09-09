import 'package:flutter/material.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:lh_community/src/ui/common/report/community_repo.dart';
import 'package:lh_community/src/ui/common/report/reason.dart';
import 'package:lh_community/src/utils/community_button.dart';
import 'package:lh_community/src/utils/community_color.dart';
import 'package:lh_community/src/utils/collection_ex.dart';
import 'package:lh_community/src/utils/dialog_util.dart';
import 'package:lh_community/src/utils/dimen_mixin.dart';
import 'package:lh_community/src/utils/res.dart';
import 'package:lh_community/src/utils/selected_widget.dart';
import 'package:lh_community/src/utils/text_style.dart';

enum ReportTarget { post, user, comment }

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    super.key,
    required this.reports,
    required this.target,
    required this.targetID,
  });

  final List<CMReason> reports;
  final String target;
  final int targetID;

  @override
  State<ReportDialog> createState() => _State();

  static Future<bool?> show(ReportTarget target, dynamic targetID) async {
    ReportRepo cubit = ReportRepo();
    List<CMReason> reports = [];
    reports = await cubit.getReportList();
    if (reports.isNotEmpty) {
      return showGeneralDialog(
        context: LHCommunity().context,
        barrierLabel: '',
        transitionBuilder: (context, a1, a2, _) {
          var curve = Curves.easeInOut.transform(a1.value);
          return Opacity(
            opacity: a1.value,
            child: Transform.scale(
              scale: curve,
              child: Dialog(
                backgroundColor: CMColor.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                insetPadding:
                    EdgeInsets.symmetric(horizontal: Dimen.isTablet ? 157 : 20),
                child: ReportDialog(
                  reports: reports,
                  target: target.name,
                  targetID: targetID,
                ),
              ),
            ),
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SizedBox();
        },
      );
    } else {
      return null;
    }
  }
}

class _State extends State<ReportDialog> {
  @override
  void initState() {
    super.initState();
    list = widget.reports;
  }

  static String titleForTarget(String target) {
    if (target == ReportTarget.comment.name) {
      return cmStr.report_comment_desc;
    }
    if (target == ReportTarget.user.name) {
      return cmStr.report_user_desc;
    }
    if (target == ReportTarget.post.name) {
      return cmStr.report_post_desc;
    }
    return '';
  }

  final ReportRepo _cubit = ReportRepo();

  List<CMReason> list = [];
  List<CMReason> selectedList = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cmStr.report_reason_popup_title,
                style: LHTextStyle.title1,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Text(
                titleForTarget(widget.target),
                style: LHTextStyle.button3_1.copyWith(color: CMColor.grey6),
              ),
              buildContent(),
              Row(
                children: [
                  Expanded(
                    child: CMAppButton.outline(
                      text: cmStr.text_cancel,
                      borderColor: CMColor.grey6,
                      textColor: CMColor.grey7,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CMAppButton(
                      enable: selectedList.isNotEmpty,
                      text: cmStr.report_submit_btn,
                      onTap: selectedList.isEmpty
                          ? null
                          : () async {
                              if (selectedList.notNullOrEmpty) {
                                bool complete = await _cubit.createReportList(
                                    ReportRequestModel(
                                        target: widget.target,
                                        targetId: widget.targetID,
                                        type: selectedList.firstOrNull?.type,
                                        reasons: selectedList
                                            .map((e) => CMReason(
                                                id: e.id,
                                                type: e.type,
                                                reason: e.reason))
                                            .toList()));
                                if (complete) {
                                  AppDialog.showSuccessToast(
                                      msg: cmStr.report_completed_successfully);

                                  Navigator.of(context).pop(true);
                                  return;
                                }
                                Navigator.of(context).pop(false);
                              }
                            },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  buildContent() {
    return Flexible(
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        itemBuilder: (context, index) {
          final selected = selectedList.contains(list[index]);
          return InkWell(
            onTap: () {
              if (!selected) {
                selectedList.add(list[index]);
              } else {
                selectedList.remove(list[index]);
              }
              setState(() {});
            },
            child: Row(
              children: [
                AbsorbPointer(
                  absorbing: true,
                  child: AppCheckBox2(
                    onChange: (select) {},
                    initialValue: selected,
                  ),
                ),
                Dimen.sBWidth8,
                Text(
                  list[index].reason ?? '',
                  style: LHTextStyle.message14,
                )
              ],
            ),
          );
        },
        shrinkWrap: true,
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(
          height: 16,
        ),
      ),
    );
  }
}
