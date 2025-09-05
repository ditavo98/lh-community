import 'package:dio/dio.dart';
import 'package:lh_community/src/interceptors/awesome_dio_interceptor.dart';
import 'package:lh_community/src/interceptors/community_interceptor.dart';

class DioClient {
  static Dio setup() {
    final Dio dio = Dio();
    BaseOptions options = BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    );
    dio.options = options;
    dio.interceptors.add(CommunityInterceptor(dio));
    dio.interceptors.add(AwesomeDioInterceptor());
    return dio;
  }
}
