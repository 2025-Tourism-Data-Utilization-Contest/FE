import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:showings/settings/user.dart';
import 'package:showings/widgets/post/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../settings/call_api.dart';

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});

  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<File> _selectedImages = [];
  int _currentPage = 0; // ✅ 여기에 추가!

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 접근 권한이 필요합니다.')),
        );
        return;
      }
    }

    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(); // ✅ 여러 장 선택

    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<User> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('user');
    if (jsonStr != null) {
      return User.fromJson(jsonDecode(jsonStr));
    } else {
      return User(name: '홍길동', profileImageUrl: '');
    }
  }

  void _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용이나 이미지를 입력해주세요.')),
      );
      return;
    }

    try {
      final user = await loadUser();

      // 이미지 업로드
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        uploadedImageUrls = await uploadImagesAndGetUrls(_selectedImages,"post");
        print('📸 업로드된 URL들: $uploadedImageUrls');
      }

      final tags = _tagController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        user: user,
        createdAt: DateTime.now(),
        type: PostType.normal,
        content: content,
        imageUrls: uploadedImageUrls,
        tags: tags,
      );

      await PostService.createPost(
        title: content.length > 20 ? content.substring(0, 20) : content,
        content: content,
        postType: 'NORMAL',
        imageUrls: uploadedImageUrls,
        hashtags: tags,
      );

      Navigator.pop(context, post);
    } catch (e) {
      print('❌ 업로드 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게시글 작성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSelector(),
            const SizedBox(height: 16),
            _buildTagField(),
            const SizedBox(height: 16),
            _buildContentField(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    final hasImages = _selectedImages.isNotEmpty;

    return GestureDetector(
      onTap: _pickImages, // 이미지가 있든 없든 탭 시 이미지 다시 고름
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: hasImages
            ? Stack(
          children: [
            PageView.builder(
              itemCount: _selectedImages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (_, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImages[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (_selectedImages.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _selectedImages.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.grey[500],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        )
            : Center(
          child: Icon(Icons.add, size: 48, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildTagField() {
    return TextField(
      controller: _tagController,
      decoration: const InputDecoration(
        hintText: '태그 입력 (쉼표로 구분)',
        prefixIcon: Icon(Icons.tag),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      maxLines: 6,
      decoration: const InputDecoration(
        hintText: '무엇을 기록하고 싶으신가요?',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitPost,
          child: const Text('작성 완료'),
        ),
      ),
    );
  }

}
