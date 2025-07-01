import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 👈 이거 추가
import 'settings/thema.dart';
import 'screens/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'showings',
      theme: appTheme,
      home: LoginScreen(),
      localizationsDelegates: const [ // 👈 이거 추가
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [ // 👈 이거도 추가
        Locale('ko', ''), // 한국어 지원
        Locale('en', ''), // 영어도 포함 (보통 기본)
      ],
    );
  }
}
