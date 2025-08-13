import 'package:flutter/material.dart';

const String dayMapStyle = '''
[
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
    "stylers": [
      { "color": "#2e2e3a" }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#B0B0C0" }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#1f1f2b" }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      { "color": "#4B4B66" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      { "color": "#4a4a5a" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#2e2e3a" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#8a8a9c" }
    ]
  },
  {
    "featureType": "transit",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "featureType": "water",
    "stylers": [
      { "color": "#65647B" }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      { "color": "#324d3d" }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      { "color": "#3b3b50" }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#5c5c78" }, { "weight": 0.6 }
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "geometry",
    "stylers": [
      { "color": "#3e3e4d" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#4e4e65" }, { "weight": 0.2 }
    ]
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


