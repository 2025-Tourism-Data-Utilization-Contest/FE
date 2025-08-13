import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:showings/widgets/place_card.dart';
import 'package:showings/screens/course_detail_page.dart';
import '../screens/detail_page.dart';
import '../settings/call_api.dart';
import '../settings/travel_course.dart';
import '../settings/travel_day.dart';
import '../settings/user.dart';

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
  DateTime? startDate;
  DateTime? endDate;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

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
                onTagPressed: (tag) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BirdDetailScreen(),
                    ),
                  );
                },
                onMorePressed: () {
                  // 더보기 버튼 눌렀을 때
                },
                showImage: true,
              ),
              const SizedBox(height: 24),
              const Text(
                '여행일정',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              DateSelector(
                label: '가는 날',
                initialDate: startDate,
                onDateSelected: (date) {
                  setState(() {
                    startDate = date;
                  });
                },
              ),
              const SizedBox(height: 12),
              DateSelector(
                label: '오는 날',
                initialDate: endDate,
                onDateSelected: (date) {
                  setState(() {
                    endDate = date;
                  });
                },
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
          onPressed: isSubmitting ? null : () async {
            if (startDate == null || endDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('가는 날과 오는 날을 선택해주세요')),
              );
              return;
            }

            try {
              setState(() => isSubmitting = true);

              final fmt = DateFormat('yyyy-MM-dd');
              final startStr = fmt.format(startDate!);
              final endStr   = fmt.format(endDate!);

              final result = await RouteService.createRoute(
                startDate: startStr,
                endDate: endStr,
              );

              final routeId = result['data'] as int; // 서버가 준 id

              final user = await loadUser();
              final daysCount = endDate!.difference(startDate!).inDays + 1;

              final travelCourse = TravelCourse(
                startDate: startDate!,
                endDate: endDate!,
                title: "",
                days: List.generate(daysCount, (_) => TravelDay(places: [])),
                author: user,
                id : routeId,
              );

              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TravelCourseDetailScreen(travelCourse: travelCourse),
                ),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('루트 생성 실패: $e')),
              );
            } finally {
              if (mounted) setState(() => isSubmitting = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B3A57),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
          ),
          child: isSubmitting
              ? const SizedBox(
            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('다음으로', style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }
}

class DateSelector extends StatefulWidget {
  final String label;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelector({
    super.key,
    required this.label,
    this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}


class _DateSelectorState extends State<DateSelector> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko'),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDateSelected(picked); // 선택한 날짜 부모로 전달
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12), // ⬅ horizontal 제거
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16), // 좌측 여백은 여기서만 한 번 주기
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
              const SizedBox(width: 16), // 우측 여백도 맞춰줌
            ],
          ),
        ),
      ),
    );
  }

  String _weekdayToStr(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }
}

