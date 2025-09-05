import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lh_community/src/lh_community.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class CommunityInterceptor extends Interceptor {
  Dio dio;

  CommunityInterceptor(this.dio);

  PackageInfo? _packageInfo;
  String? _timezone;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _packageInfo ??= await PackageInfo.fromPlatform();
    _timezone ??= await FlutterTimezone.getLocalTimezone();
    Map<String, String> headers = {};
    headers['accept'] = 'application/json';
    /* if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }*/
    headers['Accept-Language'] = LHCommunity().appLanguage;
    headers['appVersion'] = _packageInfo!.version;
    headers['appBuild'] = _packageInfo!.buildNumber;
    headers['X-Client-Platform'] = Platform.isAndroid ? 'AOS' : 'IOS';
    headers['X-Client-App-Id'] = _packageInfo!.packageName;
    headers['x-api-key'] = LHCommunity().apiKey;
    headers['x-domain'] = LHCommunity().domain;
    headers['x-user-id'] = LHCommunity().userId;
    headers['x-timezone'] = _timezone ?? '';
    options.headers = headers;
    return super.onRequest(options, handler);
  }
}
