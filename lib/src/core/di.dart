import 'package:get_it/get_it.dart';
import 'package:lh_community/src/core/api/api_client.dart';
import 'package:lh_community/src/core/configs.dart';
import 'package:lh_community/src/core/dio_client.dart';

GetIt getIt = GetIt.instance;

class DependenceInjection {
  static init() async {
    getIt.registerFactory<ApiClient>(
      () => ApiClient(DioClient.setup(), baseUrl: LHConfigs.baseUrl),
    );
  }
}
