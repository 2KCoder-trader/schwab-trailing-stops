import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

class AuthService {
  static const String redirectUri = 'https://trade.dataflexlab.com';

  // In dev (localhost) call the local wrangler instance; in prod call the deployed worker.
  static String get _apiBase {
    final host = web.window.location.hostname;
    if (host == 'localhost' || host == '127.0.0.1') {
      return 'http://localhost:8787';
    }
    return 'https://trail-stop-api.kaidenkrenek.workers.dev';
  }

  // Token storage (in-memory for web)
  static String? _accessToken;
  static String? _refreshToken;
  static DateTime? _accessTokenExpiry;
  static DateTime? _refreshTokenExpiry;

  static bool get hasValidRefreshToken {
    if (_refreshToken == null || _refreshTokenExpiry == null) return false;
    return DateTime.now().isBefore(_refreshTokenExpiry!);
  }

  static bool get hasValidAccessToken {
    if (_accessToken == null || _accessTokenExpiry == null) return false;
    return DateTime.now().isBefore(_accessTokenExpiry!);
  }

  static String? get accessToken => _accessToken;

  static Future<void> redirectToLogin() async {
    final response = await http.get(Uri.parse('$_apiBase/auth-url'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      web.window.location.href = data['url'] as String;
    }
  }

  static String? getAuthCodeFromUrl() {
    final uri = Uri.parse(web.window.location.href);
    final code = uri.queryParameters['code'];
    if (code != null) {
      web.window.history.replaceState(null, '', '/');
    }
    return code;
  }

  static Future<bool> exchangeCodeForTokens(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBase/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode != 200) {
        print('Token exchange failed: ${response.statusCode} ${response.body}');
        return false;
      }

      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
      _accessTokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in'] ?? 1800));
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
        Uri.parse('$_apiBase/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      );

      if (response.statusCode != 200) {
        print('Token refresh failed: ${response.statusCode} ${response.body}');
        return false;
      }

      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
      _accessTokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in'] ?? 1800));
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
