import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings/thema.dart';
import 'screens/login_page.dart';
import 'settings/load_csv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadDistrictMap();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // 👈 모든 키-값 제거// 👈 여기에 한 번만 실행
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: { '/login': (context) => LoginScreen() },
      debugShowCheckedModeBanner: false,
      title: 'showings',
      theme: appTheme,
      home: LoginScreen(),
      localizationsDelegates: const [
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
