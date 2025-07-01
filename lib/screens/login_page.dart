import 'package:flutter/material.dart';
import 'package:showings/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _showIdError = false;
  bool _showPwError = false;
  bool _rememberId = false;

  void _onLoginPressed() {
    setState(() {
      _showIdError = _idController.text != 'abcde1234';
      _showPwError = _pwController.text != 'password123';
    });

    if (!_showIdError && !_showPwError) {
      // 로그인 성공 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text('앱 로고', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Text('로그인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _idController,
                label: '아이디',
                error: _showIdError,
                errorText: '아이디 혹은 비밀번호가 맞지 않습니다.',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _pwController,
                label: '비밀번호',
                obscure: true,
                error: _showPwError,
                errorText: '아이디 혹은 비밀번호가 맞지 않습니다.',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _rememberId,
                    onChanged: (value) {
                      setState(() {
                        _rememberId = value ?? false;
                      });
                    },
                  ),
                  const Text('아이디 저장'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('아이디 찾기'),
                  Text('비밀번호 찾기'),
                  Text('회원가입'),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onLoginPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B3A57),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(36),
                  ),
                ),
                child: const Text('확인', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                  label: const Text('카카오로 시작하기', style: TextStyle(color: Colors.black)),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(), // 이동할 페이지로 교체
                    ),
                  );
                },
                child: const Text(
                  '로그인 없이 계속하기',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    bool error = false,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        errorText: error ? errorText : null,
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => setState(() => controller.clear()),
        )
            : null,
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}
