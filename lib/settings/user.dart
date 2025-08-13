import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> saveUser(User user) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = jsonEncode(user.toJson());
  await prefs.setString('user', jsonStr);
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


class User {
  final String name;
  final String profileImageUrl;

  User({
    required this.name,
    required this.profileImageUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.name == name &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode => name.hashCode ^ profileImageUrl.hashCode;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      profileImageUrl: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profileImageUrl': profileImageUrl,
    };
  }
}
