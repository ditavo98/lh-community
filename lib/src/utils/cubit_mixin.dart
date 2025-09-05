import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lh_community/src/core/model/base/base_response.dart';
import 'package:lh_community/src/utils/loading_screen.dart';
import 'package:lh_community/src/utils/map_ex.dart';
import 'package:lh_community/src/utils/string_ex.dart';

mixin CubitMixin<T> on Cubit<T> {
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  Future apiCall<D>({
    required Future<BaseResponse<D>> callToHost,
    required Function(D data) success,
    Function(String)? error,
    Function()? successNoData,
    Function()? actionOk,
    bool showLoading = false,
    bool autoHideLoading = true,
  }) async {
    final Stopwatch stopwatch = Stopwatch();
    if (showLoading) {
      stopwatch.start();
      LHLoadingScreen.show();
    }
    try {
      final call = await callToHost;
      if (showLoading) {
        stopwatch.stop();
        var executeTime = stopwatch.elapsedMilliseconds;
        final remainingTime = 300 - executeTime;
        if (remainingTime > 0) {
          await Future.delayed(Duration(milliseconds: remainingTime));
        }
        LHLoadingScreen.close();
      }
      if (call.success == true) {
        return success(call.data as D);
      }
    } on DioException catch (err) {
      if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
        if (showLoading) {
          stopwatch.stop();
          LHLoadingScreen.close();
        }
        return error?.call('');
      }
      if (showLoading) {
        stopwatch.stop();
        LHLoadingScreen.close();
      }
      try {
        var validations = err.response?.data['validation'] as List?;
        final invalidList = (validations ?? [])
            .map((v) => (v as Map?).strOrNull('message'))
            .toList();
        String msg = invalidList.whereType<String>().join('\n');
        if (msg.notNullOrEmpty) {
          return error?.call(msg);
        }
        var messages = err.response?.data['message'];
        if (messages is List) {
          msg = messages.whereType<String>().join('\n');
        } else if (messages is String) {
          msg = messages;
        }
        return error?.call(msg);
      } catch (_) {
        return error?.call('');
      }
    } catch (err, s) {
      if (showLoading) {
        stopwatch.stop();
        LHLoadingScreen.close();
      }
      error?.call('');
    }
  }
}
