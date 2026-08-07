import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("access_token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("access_token");
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("name");
  }

  static Future<String?> getProfileImageUrl() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("profile_image_url");
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("user_id", user["user_id"].toString());

    await prefs.setString("role", user["role"] ?? "farmer");

    await prefs.setString("name", user["name"] ?? "");

    final profileImageUrl =
        [
          user["profile_image_url"],
          user["avatar_url"],
          user["profile_image"],
          user["image_url"],
          user["photo_url"],
        ].firstWhere(
          (value) => value != null && value.toString().isNotEmpty,
          orElse: () => "",
        );

    await prefs.setString("profile_image_url", profileImageUrl.toString());
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
