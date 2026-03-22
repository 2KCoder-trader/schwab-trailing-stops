import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

class AuthService {
  static String get _appKey =>
      const String.fromEnvironment('APP_KEY', defaultValue: 'YOUR_APP_KEY');
  static String get _appSecret =>
      const String.fromEnvironment('APP_SECRET', defaultValue: 'YOUR_APP_SECRET');
  static const String redirectUri = 'https://127.0.0.1:8080';
  static String get authUrl =>
      'https://api.schwabapi.com/v1/oauth/authorize?client_id=$_appKey&redirect_uri=$redirectUri';
  static const String tokenUrl = 'https://api.schwabapi.com/v1/oauth/token';

  // Token storage (in-memory for web, use flutter_secure_storage for mobile)
  static String? _accessToken;
  static String? _refreshToken;
  static DateTime? _accessTokenExpiry;
  static DateTime? _refreshTokenExpiry;

  static String get _basicAuth =>
      base64Encode(utf8.encode('$_appKey:$_appSecret'));

  static bool get hasValidRefreshToken {
    if (_refreshToken == null || _refreshTokenExpiry == null) return false;
    return DateTime.now().isBefore(_refreshTokenExpiry!);
  }

  static bool get hasValidAccessToken {
    if (_accessToken == null || _accessTokenExpiry == null) return false;
    return DateTime.now().isBefore(_accessTokenExpiry!);
  }

  static String? get accessToken => _accessToken;

  static void redirectToLogin() {
    web.window.location.href = authUrl;
  }

  static String? getAuthCodeFromUrl() {
    final uri = Uri.parse(web.window.location.href);
    final code = uri.queryParameters['code'];
    if (code != null) {
      web.window.history.replaceState(null, '', redirectUri);
    }
    return code;
  }

  static Future<bool> exchangeCodeForTokens(String code) async {
    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Authorization': 'Basic $_basicAuth',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body:
            'grant_type=authorization_code&code=${Uri.encodeComponent(code)}&redirect_uri=${Uri.encodeComponent(redirectUri)}',
      );

      if (response.statusCode != 200) {
        print('Token exchange failed: ${response.statusCode} ${response.body}');
        return false;
      }

      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      _accessTokenExpiry = DateTime.now().add(const Duration(minutes: 30));
      _refreshTokenExpiry = DateTime.now().add(const Duration(days: 7));
      return true;
    } catch (e) {
      print('Token exchange error: $e');
      return false;
    }
  }

  static Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Authorization': 'Basic $_basicAuth',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body:
            'grant_type=refresh_token&refresh_token=${Uri.encodeComponent(_refreshToken!)}',
      );

      if (response.statusCode != 200) {
        print('Token refresh failed: ${response.statusCode} ${response.body}');
        return false;
      }

      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _accessTokenExpiry =
          DateTime.now().add(Duration(seconds: data['expires_in'] ?? 1800));
      if (data['refresh_token'] != null) {
        _refreshToken = data['refresh_token'];
        _refreshTokenExpiry = DateTime.now().add(const Duration(days: 7));
      }
      return true;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  static Future<String?> getAccessToken() async {
    if (hasValidAccessToken) return _accessToken;
    if (hasValidRefreshToken) {
      final success = await refreshAccessToken();
      if (success) return _accessToken;
    }
    return null;
  }

  static void logout() {
    _accessToken = null;
    _refreshToken = null;
    _accessTokenExpiry = null;
    _refreshTokenExpiry = null;
  }
}
