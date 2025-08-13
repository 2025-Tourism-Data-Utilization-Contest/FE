import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:showings/screens/home_screen.dart';

final _storage = FlutterSecureStorage();

Future<void> _handleRedirectUrl(String url) async {
  final uri = Uri.parse(url);

  if (uri.scheme == 'myapp' && uri.host == 'oauth') {
    final accessToken = uri.queryParameters['accessToken'];
    final refreshToken = uri.queryParameters['refreshToken'];

    if (accessToken != null && refreshToken != null) {
      await _storage.write(key: 'accessToken', value: accessToken);
      await _storage.write(key: 'refreshToken', value: refreshToken);
      print('✅ 토큰 저장 완료');
    } else {
      print('❌ 토큰 없음');
    }
  }
}



class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  bool _isRedirecting = false;

  Future<void> _handleLoginRedirect(String url) async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    await _handleRedirectUrl(url);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📌 페이지 시작: $url');
          },
          onPageFinished: (String url) {
            print('✅ 페이지 완료: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('➡️ 네비게이션 요청: ${request.url}');
            if (request.url.startsWith('myapp://oauth')) {
              _handleLoginRedirect(request.url);  // async 처리
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: WebViewWidget(controller: controller),
    );
  }
}
