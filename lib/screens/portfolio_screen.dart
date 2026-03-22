import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/schwab_api_service.dart';
import 'trade_page.dart';

final _numFmt = NumberFormat('#,##0.00');

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  // Fake positions API response — GET /accounts/{id}?fields=positions
  static const List<Map<String, dynamic>> fakePositionsResponse = [
    {
      "securitiesAccount": {
        "positions": [
          {
            "instrument": {"symbol": "AAPL", "assetType": "EQUITY", "cusip": "037833100", "instrumentId": 1206667},
            "longQuantity": 10,
            "marketValue": 1992.30,
            "averagePrice": 180.50,
          },
          {
            "instrument": {"symbol": "AMZN", "assetType": "EQUITY", "cusip": "023135106", "instrumentId": 1234568},
            "longQuantity": 5,
            "marketValue": 9324.10,
            "averagePrice": 1800.00,
          },
          {
            "instrument": {"symbol": "NFLX", "assetType": "EQUITY", "cusip": "64110L106", "instrumentId": 1234569},
            "longQuantity": 8,
            "marketValue": 2837.92,
            "averagePrice": 372.00,
          },
          {
            "instrument": {"symbol": "GOOG", "assetType": "EQUITY", "cusip": "02079K305", "instrumentId": 1234570},
            "longQuantity": 3,
            "marketValue": 3709.02,
            "averagePrice": 1153.94,
          },
          {
            "instrument": {"symbol": "MSFT", "assetType": "EQUITY", "cusip": "594918104", "instrumentId": 1234571},
            "longQuantity": 12,
            "marketValue": 5041.80,
            "averagePrice": 390.00,
          },
        ]
      }
    }
  ];

  // Fake orders API response — GET /accounts/{id}/orders
  static const List<Map<String, dynamic>> fakeOrdersResponse = [
    {
      "session": "NORMAL",
      "duration": "GOOD_TILL_CANCEL",
      "orderType": "TRAILING_STOP",
      "complexOrderStrategyType": "NONE",
      "quantity": 10.0,
      "filledQuantity": 0.0,
      "remainingQuantity": 10.0,
      "requestedDestination": "AUTO",
      "destinationLinkName": "AutoRoute",
      "stopPriceLinkBasis": "MARK",
      "stopPriceLinkType": "VALUE",
      "stopPriceOffset": 3.0,
      "stopType": "MARK",
      "orderLegCollection": [
        {
          "orderLegType": "EQUITY",
          "legId": 1,
          "instrument": {"assetType": "EQUITY", "cusip": "037833100", "symbol": "AAPL", "instrumentId": 1206667},
          "instruction": "SELL",
          "positionEffect": "CLOSING",
          "quantity": 10.0
        }
      ],
      "orderStrategyType": "SINGLE",
      "orderId": 1005676002176,
      "cancelable": true,
      "editable": false,
      "status": "AWAITING_STOP_CONDITION",
      "enteredTime": "2026-03-11T20:04:18+0000",
      "tag": "API_TOS:SGW:TOSWeb",
      "accountNumber": 61973927
    },
    {
      "session": "NORMAL",
      "duration": "GOOD_TILL_CANCEL",
      "orderType": "TRAILING_STOP",
      "complexOrderStrategyType": "NONE",
      "quantity": 5.0,
      "filledQuantity": 0.0,
      "remainingQuantity": 5.0,
      "requestedDestination": "AUTO",
      "destinationLinkName": "AutoRoute",
      "stopPriceLinkBasis": "MARK",
      "stopPriceLinkType": "VALUE",
      "stopPriceOffset": 5.0,
      "stopType": "MARK",
      "orderLegCollection": [
        {
          "orderLegType": "EQUITY",
          "legId": 1,
          "instrument": {"assetType": "EQUITY", "cusip": "023135106", "symbol": "AMZN", "instrumentId": 1234568},
          "instruction": "SELL",
          "positionEffect": "CLOSING",
          "quantity": 5.0
        }
      ],
      "orderStrategyType": "SINGLE",
      "orderId": 1005676002177,
      "cancelable": true,
      "editable": false,
      "status": "AWAITING_STOP_CONDITION",
      "enteredTime": "2026-03-10T14:22:00+0000",
      "tag": "API_TOS:SGW:TOSWeb",
      "accountNumber": 61973927
    },
    {
      "session": "NORMAL",
      "duration": "GOOD_TILL_CANCEL",
      "orderType": "TRAILING_STOP",
      "complexOrderStrategyType": "NONE",
      "quantity": 3.0,
      "filledQuantity": 0.0,
      "remainingQuantity": 3.0,
      "requestedDestination": "AUTO",
      "destinationLinkName": "AutoRoute",
      "stopPriceLinkBasis": "MARK",
      "stopPriceLinkType": "VALUE",
      "stopPriceOffset": 4.0,
      "stopType": "MARK",
      "orderLegCollection": [
        {
          "orderLegType": "EQUITY",
          "legId": 1,
          "instrument": {"assetType": "EQUITY", "cusip": "02079K305", "symbol": "GOOG", "instrumentId": 1234570},
          "instruction": "SELL",
          "positionEffect": "CLOSING",
          "quantity": 3.0
        }
      ],
      "orderStrategyType": "SINGLE",
      "orderId": 1005676002179,
      "cancelable": true,
      "editable": false,
      "status": "AWAITING_STOP_CONDITION",
      "enteredTime": "2026-03-09T09:15:00+0000",
      "tag": "API_TOS:SGW:TOSWeb",
      "accountNumber": 61973927
    },
    {
      "session": "NORMAL",
      "duration": "GOOD_TILL_CANCEL",
      "orderType": "TRAILING_STOP",
      "complexOrderStrategyType": "NONE",
      "quantity": 12.0,
      "filledQuantity": 0.0,
      "remainingQuantity": 12.0,
      "requestedDestination": "AUTO",
      "destinationLinkName": "AutoRoute",
      "stopPriceLinkBasis": "MARK",
      "stopPriceLinkType": "VALUE",
      "stopPriceOffset": 3.0,
      "stopType": "MARK",
      "orderLegCollection": [
        {
          "orderLegType": "EQUITY",
          "legId": 1,
          "instrument": {"assetType": "EQUITY", "cusip": "594918104", "symbol": "MSFT", "instrumentId": 1234571},
          "instruction": "SELL",
          "positionEffect": "CLOSING",
          "quantity": 12.0
        }
      ],
      "orderStrategyType": "SINGLE",
      "orderId": 1005676002180,
      "cancelable": true,
      "editable": false,
      "status": "AWAITING_STOP_CONDITION",
      "enteredTime": "2026-03-08T11:30:00+0000",
      "tag": "API_TOS:SGW:TOSWeb",
      "accountNumber": 61973927
    },
  ];

  // Fake price history — GET /pricehistory
  static const Map<String, List<Map<String, dynamic>>> fakePriceHistoryResponse = {
    "AAPL": [
      {"open": 182.50, "high": 183.10, "low": 182.30, "close": 182.90, "volume": 5200, "datetime": 1773100800000},
      {"open": 183.00, "high": 185.50, "low": 182.80, "close": 185.20, "volume": 12400, "datetime": 1773104400000},
      {"open": 185.20, "high": 187.25, "low": 184.90, "close": 186.80, "volume": 9800, "datetime": 1773108000000},
      {"open": 186.80, "high": 188.40, "low": 186.50, "close": 187.90, "volume": 8300, "datetime": 1773111600000},
      {"open": 187.90, "high": 189.75, "low": 187.60, "close": 189.00, "volume": 11200, "datetime": 1773115200000},
      {"open": 189.00, "high": 192.30, "low": 188.80, "close": 191.50, "volume": 15600, "datetime": 1773118800000},
      {"open": 191.50, "high": 195.80, "low": 191.20, "close": 195.00, "volume": 18400, "datetime": 1773122400000},
      {"open": 195.00, "high": 199.50, "low": 194.80, "close": 199.23, "volume": 22100, "datetime": 1773126000000},
    ],
    "AMZN": [
      {"open": 1820.00, "high": 1835.00, "low": 1818.00, "close": 1830.00, "volume": 3200, "datetime": 1773014400000},
      {"open": 1830.00, "high": 1850.00, "low": 1828.00, "close": 1845.00, "volume": 4100, "datetime": 1773018000000},
      {"open": 1845.00, "high": 1872.50, "low": 1843.00, "close": 1870.00, "volume": 5600, "datetime": 1773021600000},
      {"open": 1870.00, "high": 1880.00, "low": 1865.00, "close": 1864.82, "volume": 4800, "datetime": 1773025200000},
    ],
    "GOOG": [
      {"open": 1180.00, "high": 1195.00, "low": 1178.00, "close": 1190.00, "volume": 2100, "datetime": 1772928000000},
      {"open": 1190.00, "high": 1210.00, "low": 1188.00, "close": 1205.00, "volume": 3400, "datetime": 1772931600000},
      {"open": 1205.00, "high": 1242.00, "low": 1200.00, "close": 1238.00, "volume": 4200, "datetime": 1772935200000},
      {"open": 1238.00, "high": 1245.50, "low": 1235.00, "close": 1236.34, "volume": 3800, "datetime": 1772938800000},
    ],
    "MSFT": [
      {"open": 395.00, "high": 400.00, "low": 394.00, "close": 398.00, "volume": 4500, "datetime": 1772841600000},
      {"open": 398.00, "high": 412.00, "low": 397.00, "close": 410.00, "volume": 6200, "datetime": 1772845200000},
      {"open": 410.00, "high": 422.80, "low": 409.00, "close": 420.00, "volume": 7800, "datetime": 1772848800000},
      {"open": 420.00, "high": 425.00, "low": 418.00, "close": 420.15, "volume": 5100, "datetime": 1772852400000},
    ],
  };

  static Map<String, dynamic>? _findTrailOrder(
      String symbol, List<Map<String, dynamic>> orders) {
    for (final order in orders) {
      if (order['orderType'] == 'TRAILING_STOP' &&
          order['status'] == 'AWAITING_STOP_CONDITION') {
        final legs = order['orderLegCollection'] as List;
        for (final leg in legs) {
          final legMap = leg as Map<String, dynamic>;
          if (legMap['instruction'] == 'SELL' &&
              legMap['instrument']['symbol'] == symbol) {
            return {
              'stopPriceOffset': (order['stopPriceOffset'] as num).toDouble(),
              'enteredTime': order['enteredTime'],
              'orderId': order['orderId'],
            };
          }
        }
      }
    }
    return null;
  }

  static double _findHighestSinceEntry(String symbol, String enteredTime,
      Map<String, List<Map<String, dynamic>>> priceHistory) {
    final candles = priceHistory[symbol];
    if (candles == null || candles.isEmpty) return 0.0;

    final enteredDt = DateTime.parse(enteredTime.replaceFirst('+0000', 'Z'));
    final enteredMs = enteredDt.millisecondsSinceEpoch;

    double highest = 0.0;
    for (final candle in candles) {
      final candleMs = (candle['datetime'] as num).toInt();
      if (candleMs >= enteredMs) {
        final high = (candle['high'] as num).toDouble();
        if (high > highest) highest = high;
      }
    }

    // If no candles after enteredTime, use all candles
    if (highest == 0.0) {
      for (final candle in candles) {
        final high = (candle['high'] as num).toDouble();
        if (high > highest) highest = high;
      }
    }

    return highest;
  }

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<Map<String, dynamic>> _positionsResponse = [];
  List<Map<String, dynamic>> _ordersResponse = [];
  Map<String, List<Map<String, dynamic>>> _priceHistoryResponse =
      PortfolioScreen.fakePriceHistoryResponse;
  Timer? _timer;
  Timer? _historyTimer;

  @override
  void initState() {
    super.initState();
    _fetchPortfolio();
    _fetchPriceHistory();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _fetchPortfolio());
    _historyTimer =
        Timer.periodic(const Duration(minutes: 10), (_) => _fetchPriceHistory());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _historyTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPortfolio() async {
    final positions = await SchwabApiService.fetchPortfolio();
    if (!mounted) return;

    if (positions == null) {
      setState(() {
        _positionsResponse = PortfolioScreen.fakePositionsResponse;
        _ordersResponse = PortfolioScreen.fakeOrdersResponse;
      });
      return;
    }

    final accountHash = await SchwabApiService.fetchAccountHash();
    if (accountHash == null || !mounted) return;

    final orders = await SchwabApiService.fetchActiveOrders(accountHash);
    if (!mounted) return;

    setState(() {
      _positionsResponse = positions;
      if (orders != null) _ordersResponse = orders;
    });
  }

  Future<void> _fetchPriceHistory() async {
    final symbolStartMs = <String, int>{};
    for (final order in _ordersResponse) {
      if (order['orderType'] == 'TRAILING_STOP' &&
          order['status'] == 'AWAITING_STOP_CONDITION') {
        final legs = order['orderLegCollection'] as List? ?? [];
        for (final leg in legs) {
          final legMap = leg as Map<String, dynamic>;
          if (legMap['instruction'] == 'SELL') {
            final symbol = legMap['instrument']['symbol'] as String;
            final enteredStr =
                (order['enteredTime'] as String).replaceFirst('+0000', 'Z');
            symbolStartMs[symbol] =
                DateTime.parse(enteredStr).millisecondsSinceEpoch;
          }
        }
      }
    }

    if (symbolStartMs.isEmpty) return;

    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    final historyEntries = await Future.wait(
      symbolStartMs.entries.map((e) async {
        final enteredDt = DateTime.fromMillisecondsSinceEpoch(e.value);
        final daysSinceEntry = now.difference(enteredDt).inDays;

        final String freqType;
        final int freq;
        final String periodType;
        if (daysSinceEntry < 2) {
          periodType = 'day';
          freqType = 'minute';
          freq = 1;
        } else if (daysSinceEntry < 7) {
          periodType = 'day';
          freqType = 'minute';
          freq = 30;
        } else {
          periodType = 'month';
          freqType = 'daily';
          freq = 1;
        }

        final candles = await SchwabApiService.fetchPriceHistory(
            e.key, e.value, nowMs,
            periodType: periodType, frequencyType: freqType, frequency: freq);
        return MapEntry(e.key, candles ?? <Map<String, dynamic>>[]);
      }),
    );

    if (!mounted) return;
    final priceHistory =
        Map<String, List<Map<String, dynamic>>>.fromEntries(historyEntries);
    if (priceHistory.isNotEmpty) setState(() => _priceHistoryResponse = priceHistory);
  }

  List<Map<String, dynamic>> get stockData {
    if (_positionsResponse.isEmpty) return [];
    final account =
        _positionsResponse[0]['securitiesAccount'] as Map<String, dynamic>?;
    final rawPositions = account?['positions'];
    if (rawPositions == null) return [];
    final positions = rawPositions as List;
    return positions.where((p) {
      final pos = p as Map<String, dynamic>;
      final String symbol = pos['instrument']['symbol'];
      return PortfolioScreen._findTrailOrder(symbol, _ordersResponse) != null;
    }).map((p) {
      final pos = p as Map<String, dynamic>;
      final String symbol = pos['instrument']['symbol'];
      final double marketValue = (pos['marketValue'] as num).toDouble();
      final int qty = (pos['longQuantity'] as num).toInt();
      final double avgPrice = (pos['averagePrice'] as num).toDouble();
      final double marketPrice = marketValue / qty;
      final double profit = (marketPrice - avgPrice) * qty;

      final trailOrder =
          PortfolioScreen._findTrailOrder(symbol, _ordersResponse);
      final bool hasTrail = trailOrder != null;

      double trailOffset = 0.0;
      double trailStop = 0.0;

      bool trailStopValid = false;
      if (hasTrail) {
        trailOffset = trailOrder['stopPriceOffset'];
        final String enteredTime = trailOrder['enteredTime'];
        final double highestHigh = PortfolioScreen._findHighestSinceEntry(
            symbol, enteredTime, _priceHistoryResponse);
        print(
            '[$symbol] enteredTime=$enteredTime highestHigh=$highestHigh candleCount=${_priceHistoryResponse[symbol]?.length ?? 0} curPrice=$marketPrice');
        if (highestHigh > 0) {
          trailStop = highestHigh - trailOffset;
          trailStopValid = true;
        }
      }

      return {
        "ticker": symbol,
        "curPrice": double.parse(marketPrice.toStringAsFixed(2)),
        "quantity": qty,
        "averagePrice": avgPrice,
        "marketValue": marketValue,
        "plDollar": double.parse(profit.toStringAsFixed(2)),
        "isPositive": profit >= 0,
        "trailOffset": trailOffset,
        "trailStop": double.parse(trailStop.toStringAsFixed(2)),
        "hasTrail": hasTrail,
        "trailStopValid": trailStopValid,
      };
    }).toList();
  }

  void _showNotImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _showNotImplemented(context, 'Menu'),
        ),
        title: const Center(
          child: Text(
            'TRAILING STOPS',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _showNotImplemented(context, 'Profile'),
              child: CircleAvatar(
                backgroundColor: Colors.grey[700],
                radius: 16,
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTab(context, 'Stocks', isSelected: true),
                _buildTab(context, 'Funds'),
                _buildTab(context, 'Options'),
                _buildTab(context, 'Bonds'),
                _buildTab(context, 'Spot'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF102A43),
                hintText: 'Search equity — not implemented yet',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onSubmitted: (_) => _showNotImplemented(context, 'Search'),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TICKER',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      Text('TRAILING GAP',
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('MARKET',
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                        Text('STOP',
                            style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 40),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('FLOATING P/L',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      Text('LOCKED PROFIT',
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: stockData.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TradePage(stock: stockData[index]),
                      ),
                    );
                  },
                  child: _buildStockRow(context, stockData[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, {bool isSelected = false}) {
    return GestureDetector(
      onTap: isSelected ? null : () => _showNotImplemented(context, '$title tab'),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStockRow(BuildContext context, Map<String, dynamic> stock) {
    Color plColor =
        stock['isPositive'] ? Colors.greenAccent : Colors.redAccent;
    double plDollar = (stock['plDollar'] as num).toDouble();
    String plSign = plDollar >= 0 ? '+' : '-';
    String plFormatted = '$plSign${_numFmt.format(plDollar.abs())}';

    bool hasTrail = stock['hasTrail'] == true;
    double curPrice = (stock['curPrice'] as num).toDouble();
    double trailStop = (stock['trailStop'] as num).toDouble();

    String guaranteedFormatted = '—';
    Color guaranteedColor = Colors.grey;
    String trailOffsetText = '—';
    String trailStopText = '—';

    if (hasTrail) {
      trailOffsetText = _numFmt.format((stock['trailOffset'] as num).toDouble());
      final bool trailStopValid = stock['trailStopValid'] == true;
      if (trailStopValid) {
        int qty = (stock['quantity'] as num).toInt();
        double avgPrice = (stock['averagePrice'] as num).toDouble();
        double guaranteed = (trailStop - avgPrice) * qty;
        if (guaranteed > 0) {
          guaranteedFormatted = '+${_numFmt.format(guaranteed)}';
          guaranteedColor = Colors.greenAccent;
        }
        trailStopText = _numFmt.format(trailStop);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock['ticker'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(trailOffsetText,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    _numFmt.format((stock['curPrice'] as num).toDouble()),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(trailStopText,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ),
          ),
          // Close position button
          SizedBox(
            width: 40,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF132F4C),
                    title: const Text('Close Position',
                        style: TextStyle(color: Colors.white)),
                    content: Text(
                      'Are you sure you want to close your ${stock['ticker']} position?',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('CANCEL',
                            style: TextStyle(color: Colors.white70)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Close position — not implemented yet'),
                            ),
                          );
                        },
                        child: const Text('CLOSE',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plFormatted,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: plColor),
                ),
                const SizedBox(height: 4),
                Text(guaranteedFormatted,
                    style:
                        TextStyle(color: guaranteedColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
