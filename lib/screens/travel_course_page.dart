import 'package:flutter/material.dart';
import 'package:showings/widgets/place_card.dart';
import 'package:showings/screens/place_add_page.dart';

class TravelCourseForm extends StatefulWidget {
  final String imageUrl;
  final String title;
  final List<String> tags;
  final String description;

  const TravelCourseForm({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.description,
  });

  @override
  State<TravelCourseForm> createState() => _TravelCourseFormState();
}

class _TravelCourseFormState extends State<TravelCourseForm> {
  String? selectedTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('여행코스 만들기'),
        centerTitle: false,
      ),

      // ✅ 메인 콘텐츠는 body에
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlaceCard(
                imageUrl: widget.imageUrl,
                title: widget.title,
                tags: widget.tags,
                description: widget.description,
                selectedTag: selectedTag, // 상태 변수로 선택된 태그 전달
                onTagPressed: (tag) {
                  setState(() {
                    selectedTag = tag; // 태그 선택 상태 갱신
                  });
                },
                onMorePressed: () {
                  // 더보기 버튼 눌렀을 때
                },
              ),
              const SizedBox(height: 24),
              const Text(
                '여행일정',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              DateSelector(label: '가는 날'),
              const SizedBox(height: 12),
              DateSelector(label: '오는 날'),
              const SizedBox(height: 24),
              const Text(
                '인원 수',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<int>(
                  value: 1,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: List.generate(10, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}명'),
                    );
                  }),
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(height: 80), // 여유 공간
            ],
          ),
        ),
      ),

      // ✅ 버튼은 여기에
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 24,
          right: 24,
          top: 8,
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTravelDestinationScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B3A57),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
            ),
          ),
          child: const Text(
            '다음으로',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class DateSelector extends StatefulWidget {
  final String label;

  const DateSelector({super.key, required this.label});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  DateTime selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko'), // 한글 지원
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const Spacer(),
            Text(
              '${selectedDate.month}월 ${selectedDate.day}일 (${_weekdayToStr(selectedDate.weekday)})',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayToStr(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }
}

