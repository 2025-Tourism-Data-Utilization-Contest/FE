import 'dart:io';
import 'package:flutter/material.dart';
import 'package:showings/widgets/post/post.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../settings/comment.dart';
import '../../settings/user.dart';
import 'package:showings/widgets/post/post_button.dart';

class NormalPostCard extends StatefulWidget {
  final Post post;
  const NormalPostCard({super.key, required this.post});

  @override
  State<NormalPostCard> createState() => _NormalPostCardState();
}

class _NormalPostCardState extends State<NormalPostCard> {
  int _currentPage = 0;
  int likeCount = 0;
  bool isLiked = false;
  late User currentUser;

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initLikeStatus();
  }

  void _initLikeStatus() async {
    currentUser = await loadUser();
    final likedMap = widget.post.likes;
    setState(() {
      isLiked = likedMap?[currentUser] ?? false;
      likeCount = widget.post.likeCount ?? 0;
    });
  }


  void _toggleLike() {
    setState(() {
      if (isLiked) {
        isLiked = false;
        likeCount--;
      } else {
        isLiked = true;
        likeCount++;
      }
      // TODO: 서버에 좋아요 상태 업데이트 요청
    });
  }

  void _addComment(String content) {
    if (content.trim().isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user: currentUser,
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    setState(() {
      widget.post.comments = (widget.post.comments ?? [])..add(newComment);
      widget.post.commentCount = (widget.post.commentCount ?? 0) + 1;
    });

    _commentController.clear();
  }


  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final images = post.imageUrls ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAuthorRow(),
            const SizedBox(height: 12),
            if (images.isNotEmpty) _buildImageSlider(images),
            const SizedBox(height: 12),
            if (post.content != null && post.content!.isNotEmpty)
              Text(
                post.content!,
                style: const TextStyle(fontSize: 15),
              ),
            const SizedBox(height: 8),
            if (post.tags != null && post.tags!.isNotEmpty)
              Wrap(
                spacing: 8,
                children: post.tags!.map((tag) {
                  return Text(
                    '#$tag',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: widget.post.user.profileImageUrl.startsWith('http')
              ? CachedNetworkImageProvider(widget.post.user.profileImageUrl)
              : FileImage(File(widget.post.user.profileImageUrl)) as ImageProvider,
          radius: 18,
        ),
        const SizedBox(width: 8),
        Text(
          widget.post.user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          _formatDate(widget.post.createdAt),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildImageSlider(List<String> imageUrls) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: PageView.builder(
            itemCount: imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final path = imageUrls[index];

              if (path.isEmpty) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 40),
                );
              }

              return GestureDetector(
                onDoubleTap: _toggleLike,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildImageWidget(path),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _buildPageIndicator(imageUrls.length),
      ],
    );
  }

  Widget _buildImageWidget(String path) {
    if (path.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image),
      );
    }

    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[300]),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
      );
    }

    final file = File(path);
    if (!file.existsSync()) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image),
      );
    }

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image),
      ),
    );
  }



  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (index) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.black87 : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey[700],
          ),
          onPressed: _toggleLike,
        ),
        const SizedBox(width: 4),
        Text('$likeCount'),
        const SizedBox(width: 32),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, size: 24, color: Colors.grey),
          onPressed: () => _showCommentsBottomSheet(context),
        ),
        const SizedBox(width: 4),
        Text('${widget.post.commentCount}'),
      ],
    );
  }

  void _showCommentsBottomSheet(BuildContext context) async {
    // 패널 열릴 때 버튼 숨김
    FabOverlayManager.temporarilyHide();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final comments = widget.post.comments ?? [];

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  '댓글',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: widget.post.comments?.length ?? 0,
                    itemBuilder: (context, index) {
                      final comment = widget.post.comments![index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundImage: comment.user.profileImageUrl.startsWith('http')
                              ? CachedNetworkImageProvider(comment.user.profileImageUrl)
                              : FileImage(File(comment.user.profileImageUrl)) as ImageProvider,
                        ),
                        title: Text(comment.user.name),
                        subtitle: Text(comment.content),
                        trailing: Text(
                          _formatDate(comment.createdAt),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: '댓글을 입력하세요...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onSubmitted: _addComment,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _addComment(_commentController.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      // 패널 닫히면 버튼 다시 보이게
      FabOverlayManager.showAgain();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
