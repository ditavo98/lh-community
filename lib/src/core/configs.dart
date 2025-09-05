import 'package:lh_community/src/core/env.dart';
import 'package:lh_community/src/lh_community.dart';

class LHConfigs {
  static String _env = 'dev';

  static setEnv(String env) => _env = env;

  static LHEnv get env => switch (_env) {
        'dev' => LHEnv.dev,
        'prod' => LHEnv.prod,
        _ => LHEnv.dev,
      };

  static String get baseUrl {
    return env.serviceDomain;
  }

  static String get mediaBaseUrl => env.mediaDomain;

  static bool get isKo {
    return ['ko', 'kr'].contains(LHCommunity().appLanguage);
  }
}
