class LHEnv {
  static LHEnv get dev => LHEnv(
    name: 'dev',
    serviceDomain: 'https://dev-api-community.leveragehero.net/api/v1/',
    mediaDomain: 'https://dev-cdn-community.leveragehero.net/',
  );

  static LHEnv get prod => LHEnv(
    name: 'prod',
    serviceDomain: 'https://api-community.leveragehero.net/api/v1/',
    mediaDomain: 'https://cdn-community.leveragehero.net/',
  );

  final String name;
  final String serviceDomain;
  final String mediaDomain;

  LHEnv({
    required this.name,
    required this.serviceDomain,
    required this.mediaDomain,
  });
}
