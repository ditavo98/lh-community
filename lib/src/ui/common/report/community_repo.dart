import 'package:flutter/foundation.dart';
import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/configs.dart';
import 'package:lh_community/src/core/di.dart';
import 'package:lh_community/src/ui/common/report/reason.dart';
import 'package:lh_community/src/utils/dialog_util.dart';
import 'package:lh_community/src/utils/loading_screen.dart';
import 'package:lh_community/src/utils/res.dart';

class ReportRepo {
  Future<List<CMReason>> getReportList() async {
    return dataReport;
    /*  LoadingScreen.show();
    try {
      final res = await getIt.get<UserApiService>().getReportReason();
      LoadingScreen.close();

      if (res.code == ApiStatus.success) {
        return dataReport;
      } else {
        AppDialog.showFailedToast(msg: res.message);
      }
    } catch (err) {
      AppDialog.showFailedToast(msg: err.toString());
      LoadingScreen.close();
    }
    return [];*/
  }

  Future<bool> createReportList(ReportRequestModel request) async {
    LHLoadingScreen.show();

    try {
      final reason = request.reasons?.firstOrNull;
      if (reason == null) return false;
      final data = {
        "reason": reason.reason,
        "type": reason.type?.toUpperCase(),
        "target": request.target,
        "targetId": request.targetId,
      };
      final res = await getIt.get<ApiClient>().createReport(data);
      LHLoadingScreen.close();

      if (res.success) {
        return true;
      } else {
        if (kDebugMode) {
          AppDialog.showFailedToast(
              msg: res.message ?? cmStr.error_something_went_wrong_try_again);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        AppDialog.showFailedToast(msg: err.toString());
      }
      LHLoadingScreen.close();
    }
    return false;
  }

  final dataReport = [
    CMReason(
        id: 1,
        reason: LHConfigs.isKo ? '성적인 콘텐츠' : 'S성적인 콘텐츠',
        type: 'copyright'),
    CMReason(
        id: 2,
        reason: LHConfigs.isKo ? '저작권을 침해하는 콘텐츠' : '저작권을 침해하는 콘텐츠',
        type: 'harm'),
    CMReason(
        id: 3,
        reason: LHConfigs.isKo ? '폭력적이거나 혐오스러운 콘텐츠' : '폭력적이거나 혐오스러운 콘텐츠',
        type: 'sexual'),
    CMReason(
        id: 4,
        reason: LHConfigs.isKo ? '유해하거나 위험한 콘텐츠' : '유해하거나 위험한 콘텐츠',
        type: 'violent')
  ];

  Future<bool> block({required String userId}) async {
    LHLoadingScreen.show();
    try {
      final data = {"targetUserId": userId};
      final res = await getIt.get<ApiClient>().blocks(data);
      if (res.success) {
        LHLoadingScreen.close();
        return true;
      } else {
        LHLoadingScreen.close();
        if (kDebugMode) {
          AppDialog.showFailedToast(
              msg: res.message ?? cmStr.error_something_went_wrong_try_again);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        AppDialog.showFailedToast(msg: err.toString());
      }
      LHLoadingScreen.close();
    }
    return false;
  }

  Future<bool> deletePost({required int postId}) async {
    LHLoadingScreen.show();
    try {
      final res = await getIt.get<ApiClient>().deletePost(postId: postId);
      if (res.success) {
        LHLoadingScreen.close();
        return true;
      } else {
        LHLoadingScreen.close();
        if (kDebugMode) {
          AppDialog.showFailedToast(
              msg: res.message ?? cmStr.error_something_went_wrong_try_again);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        AppDialog.showFailedToast(msg: err.toString());
      }
      LHLoadingScreen.close();
    }
    return false;
  }

  Future<bool> deleteComment({required int commentId}) async {
    LHLoadingScreen.show();
    try {
      final res =
          await getIt.get<ApiClient>().deleteComment(commentId: commentId);
      if (res.success) {
        LHLoadingScreen.close();
        return true;
      } else {
        LHLoadingScreen.close();
        if (kDebugMode) {
          AppDialog.showFailedToast(
              msg: res.message ?? cmStr.error_something_went_wrong_try_again);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        AppDialog.showFailedToast(msg: err.toString());
      }
      LHLoadingScreen.close();
    }
    return false;
  }
}
