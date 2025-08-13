import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showings/screens/home_screen.dart';
import 'package:showings/screens/login_webview_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage();

void loadTokens() async {
  final accessToken = await _storage.read(key: 'accessToken');
  final refreshToken = await _storage.read(key: 'refreshToken');

  print('🔥 accessToken: $accessToken');
  print('🔥 refreshToken: $refreshToken');
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.png', // 너 이미지 경로에 맞게 수정
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const SizedBox(height: 16),
                  const Spacer(),

                  const Text(
                    '간편 로그인으로 시작하세요',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // 네이버 로그인
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WebViewPage(
                            url: 'https://api.saeroksaerok.site/oauth2/authorization/naver',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF03C75A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Image.asset(
                          'assets/images/naver_login.png',
                          height: 60, // 로고 크기 (텍스트 안 뭉개질 정도로)
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 카카오 로그인
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WebViewPage(
                            url: 'https://api.saeroksaerok.site/oauth2/authorization/kakao',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE500),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16), // 이미지 좌우 여백
                      child: Center(
                        child: Image.asset(
                          'assets/images/kakao_login.png',
                          height: 60, // 로고 크기 (텍스트 안 뭉개질 정도로)
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 로그인 없이 계속하기
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Text(
                      '로그인 없이 계속하기',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> clearAllPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // 모든 데이터 삭제
}

