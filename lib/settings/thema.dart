import 'package:flutter/material.dart';

const String dayMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#ffffff"}] // 배경 흰색
  },
  {
    "featureType": "water",
    "stylers": [{"color": "#DFF6E8"}] // 낮-바다부분
  },
  {
    "featureType": "road",
    "stylers": [{"color": "#E6F4EB"}] // 낮-길
  },
  {
    "featureType": "landscape",
    "stylers": [{"color": "#C7E5D3"}] // 낮-고지대
  },
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  }
]
''';



const String nightMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#65647B"}] // 밤-바다 부분 배경 통일
  },
  {
    "featureType": "water",
    "stylers": [{"color": "#65647B"}] // 밤-바다
  },
  {
    "featureType": "landscape",
    "stylers": [{"color": "#848395"}] // 밤-육지 부분
  },
  {
    "featureType": "road",
    "stylers": [{"color": "#9392A9"}] // 밤-길
  },
  {
    "featureType": "administrative",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#A8A7BB"}] // 밤-고지대
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  }
]
''';




class AppColors {
  static const primary = Color(0xFF1A73E8);
  static const secondary = Color(0xFF34A853);
  static const background = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF777777);
  static const divider = Color(0xFFDDDDDD);
}

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}

ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Pretendard',
  textTheme: const TextTheme(
    titleLarge: AppTextStyles.title,
    titleMedium: AppTextStyles.subtitle,
    bodyMedium: AppTextStyles.body,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(AppColors.primary),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
  ),
);


