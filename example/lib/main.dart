import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lh_community/generated/l10n.dart';
import 'package:lh_community/lh_community.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigationKey = GlobalKey();

  @override
  void initState() {
    LHCommunity().init(
      userId: '5',
      apiKey: 'startalk-fans-2025',
      domain: 'ai.startalk',
      navigationKey: _navigationKey,
      nickname: 'Al',
      avatar:
          "https://cdn.startalk.app/startalk/prod/user/profile/profileThumb_rabbit.svg",
    );
    Future.delayed(Duration(seconds: 2), () {
      LHCommunity().updatePostType([
        CMPostTypePartnerData(
          id: "6",
          nickname: "남궁진",
          avatar:
              "https://cdn.startalk.app/startalk/prod/user/profile/6/f24fbf7f1783-1753851319.jpg",
          message: "hiii",
        ),
      ]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CMModifyPostCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Color(0xFF6F52FF),
          ),
          useMaterial3: true,
          fontFamily: 'Pretendard',
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Color(0xFF6F52FF)),
          ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          appBarTheme: const AppBarTheme(surfaceTintColor: Colors.white),
        ),
        navigatorKey: _navigationKey,
        home: CommunityPage(),
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
          CMS.delegate,
        ],
        locale: Locale('ko'),
        builder: (ctx, child) {
          Widget widget = Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.noScaling),
                    child: child ?? const SizedBox(),
                  );
                },
              ),
            ],
          );
          return widget;
        },
      ),
    );
  }

  @override
  void dispose() {
    LHCommunity().dispose();
    super.dispose();
  }
}
