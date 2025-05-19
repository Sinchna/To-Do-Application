import 'dart:io';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class UserService {
  static Future<ParseUser?> login(String username, String password) async {
    final user = ParseUser(username, password, null);
    final response = await user.login();
    return response.success ? user : null;
  }

  static Future<ParseUser?> signup(String username, String email, String password) async {
    final user = ParseUser(username, password, email);
    final response = await user.signUp();
    return response.success ? user : null;
  }

  static Future<void> logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) await user.logout();
  }

  static Future<ParseUser?> getCurrentUser() async {
    return await ParseUser.currentUser() as ParseUser?;
  }

  /// Get profile info including profilePic URL
  static Future<Map<String, String>?> getProfile() async {
    final user = await getCurrentUser();
    if (user == null) return null;

    await user.fetch();

    return {
      'username': user.username ?? '',
      'email': user.emailAddress ?? '',
      'profilePic': user.get<String>('profilePhoto') ?? '',
    };
  }

  /// Uploads image to Parse and returns URL
  static Future<String> uploadProfileImage(File imageFile) async {
    final parseFile = ParseFile(imageFile);
    final response = await parseFile.save();

    if (response.success && parseFile.url != null) {
      return parseFile.url!;
    } else {
      throw Exception('Image upload failed');
    }
  }

  /// Update profile with username, email and optionally imageFile
  /// If removeImage is true, clears the profilePhoto field
  static Future<bool> updateProfile({
    required String username,
    required String email,
    File? imageFile,
    bool removeImage = false,
  }) async {
    final user = await getCurrentUser();
    if (user == null) return false;

    user.username = username;
    user.emailAddress = email;

    if (removeImage) {
      user.unset('profilePhoto');
    } else if (imageFile != null) {
      try {
        final imageUrl = await uploadProfileImage(imageFile);
        user.set<String>('profilePhoto', imageUrl);
      } catch (e) {
        return false;
      }
    }

    final response = await user.save();
    return response.success;
  }
}
