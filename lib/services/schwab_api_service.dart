import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'auth_service.dart';

class SchwabApiService {
  static const String _baseUrl = 'https://api.schwabapi.com/trader/v1';
  static const String _marketDataUrl = 'https://api.schwabapi.com/marketdata/v1';

  static String? _cachedAccountHash;

  /// Fetch the account hash for the first linked account.
  /// GET /trader/v1/accounts/accountNumbers
  /// Returns: [{"accountNumber": "...", "hashValue": "..."}]
  static Future<String?> fetchAccountHash() async {
    if (_cachedAccountHash != null) return _cachedAccountHash;

    final token = await AuthService.getAccessToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/accounts/accountNumbers'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        print('fetchAccountHash failed: ${response.statusCode} ${response.body}');
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) {
        print('fetchAccountHash unexpected shape: $decoded');
        return null;
      }

      _cachedAccountHash = decoded[0]['hashValue'] as String?;
      return _cachedAccountHash;
    } catch (e) {
      print('fetchAccountHash error: $e');
      return null;
    }
  }

  static Future<double?> fetchQuote(String symbol) async {
    final token = await AuthService.getAccessToken();
    if (token == null) return null;

    try {
      final encoded = Uri.encodeComponent(symbol);
      final response = await http.get(
        Uri.parse('$_marketDataUrl/$encoded/quotes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        print('Quote fetch failed: ${response.statusCode} ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data[symbol.toUpperCase()]['quote']['lastPrice'] as num).toDouble();
    } catch (e) {
      print('Quote fetch error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchPortfolio() async {
    final token = await AuthService.getAccessToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/accounts?fields=positions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        print('fetchPortfolio unexpected shape: $decoded');
        return null;
      }
      return decoded.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      print('Portfolio fetch error: $e');
      return null;
    }
  }

  static Future<bool> placeOrder(String accountHash, Map<String, dynamic> order) async {
    final token = await AuthService.getAccessToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/$accountHash/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(order),
      );

      if (response.statusCode != 201) {
        print('Place order failed: ${response.statusCode} ${response.body}');
        return false;
      }

      return true;
    } catch (e) {
      print('Place order error: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchActiveOrders(String accountHash) async {
    final token = await AuthService.getAccessToken();
    print(
        'calling fetchActiveOrders with accountHash: $accountHash and token: ${token != null ? '[REDACTED]' : 'null'}');
    if (token == null) return null;

    final now = DateTime.now().toUtc();
    final from = now.subtract(const Duration(days: 60));
    final fmt = DateFormat("yyyy-MM-dd'T'HH:mm:ss'.000Z'");
    final toStr = fmt.format(now);
    final fromStr = fmt.format(from);

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/accounts/$accountHash/orders').replace(queryParameters: {
          'fromEnteredTime': fromStr,
          'toEnteredTime': toStr,
          'status': 'AWAITING_STOP_CONDITION',
        }),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('fetchActiveOrders status: ${response.statusCode}');
      print('fetchActiveOrders body: ${response.body}');

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        print('fetchActiveOrders unexpected shape: $decoded');
        return null;
      }
      return decoded.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      print('Fetch orders error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchPriceHistory(
      String symbol, int startDateMs, int endDateMs,
      {String periodType = 'month', String frequencyType = 'daily', int frequency = 1}) async {
    final token = await AuthService.getAccessToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$_marketDataUrl/pricehistory').replace(queryParameters: {
          'symbol': symbol,
          'periodType': periodType,
          'frequencyType': frequencyType,
          'frequency': frequency.toString(),
          'startDate': startDateMs.toString(),
          'endDate': endDateMs.toString(),
        }),
        headers: {'Authorization': 'Bearer $token'},
      );
      print(
          'priceHistory $symbol ($frequencyType/$frequency): status=${response.statusCode} body=${response.body.substring(0, response.body.length.clamp(0, 200))}');

      if (response.statusCode != 200) {
        print('Price history failed $symbol: ${response.statusCode} ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candles = data['candles'];
      if (candles is! List) return null;
      return candles.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      print('Price history error $symbol: $e');
      return null;
    }
  }
}
