import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/schwab_api_service.dart';

class TradePage extends StatefulWidget {
  final Map<String, dynamic> stock;
  final bool showBack;
  const TradePage({super.key, required this.stock, this.showBack = true});

  @override
  State<TradePage> createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  final TextEditingController _tickerController = TextEditingController();
  final TextEditingController _quantityController =
      TextEditingController(text: '100');
  final TextEditingController _limitPriceController = TextEditingController();
  final TextEditingController _trailGapController =
      TextEditingController(text: '5.00');

  double? _livePrice;
  bool _quoteFetching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tickerController.text = widget.stock['ticker'] ?? 'AAPL';
    _limitPriceController.text =
        (widget.stock['curPrice'] ?? 199.23).toStringAsFixed(2);
    _tickerController.addListener(_onTickerChanged);
    _fetchQuote(_tickerController.text);
  }

  void _onTickerChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _fetchQuote(_tickerController.text);
    });
  }

  Future<void> _fetchQuote(String symbol) async {
    final s = symbol.trim().toUpperCase();
    if (s.isEmpty) return;
    setState(() => _quoteFetching = true);
    final price = await SchwabApiService.fetchQuote(s);
    if (!mounted) return;
    setState(() {
      _quoteFetching = false;
      if (price != null) {
        _livePrice = price;
        _limitPriceController.text = price.toStringAsFixed(2);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tickerController.removeListener(_onTickerChanged);
    _tickerController.dispose();
    _quantityController.dispose();
    _limitPriceController.dispose();
    _trailGapController.dispose();
    super.dispose();
  }

  double get curPrice =>
      _livePrice ?? (widget.stock['curPrice'] ?? 0).toDouble();

  static final NumberFormat _commaFormat = NumberFormat('#,##0.00');

  double get orderCost {
    double qty = double.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_limitPriceController.text) ?? 0;
    return qty * price;
  }

  String get orderCostFormatted => _commaFormat.format(orderCost);

  Map<String, dynamic> buildOrderJson() {
    final ticker = _tickerController.text.toUpperCase();
    final qty = int.tryParse(_quantityController.text) ?? 1;
    final limitPrice = _limitPriceController.text;
    final trailGap = double.tryParse(_trailGapController.text) ?? 5.0;

    return {
      "orderType": "LIMIT",
      "session": "NORMAL",
      "price": limitPrice,
      "duration": "GOOD_TILL_CANCEL",
      "orderStrategyType": "TRIGGER",
      "orderLegCollection": [
        {
          "instruction": "BUY",
          "quantity": qty,
          "instrument": {
            "symbol": ticker,
            "assetType": "EQUITY",
          },
        }
      ],
      "childOrderStrategies": [
        {
          "complexOrderStrategyType": "NONE",
          "orderType": "TRAILING_STOP",
          "session": "NORMAL",
          "stopPriceLinkBasis": "BID",
          "stopPriceLinkType": "VALUE",
          "stopPriceOffset": trailGap,
          "duration": "GOOD_TILL_CANCEL",
          "orderStrategyType": "SINGLE",
          "orderLegCollection": [
            {
              "instruction": "SELL",
              "quantity": qty,
              "instrument": {
                "symbol": ticker,
                "assetType": "EQUITY",
              },
            }
          ],
        }
      ],
    };
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.number,
      TextCapitalization caps = TextCapitalization.none}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: caps,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF102A43),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1929),
        elevation: 0,
        leading: widget.showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: _tickerController,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.white30, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.white70, width: 2),
                          ),
                          suffixIcon: const Icon(Icons.edit,
                              size: 14, color: Colors.white38),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _quoteFetching
                        ? const SizedBox(
                            height: 48,
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white38, strokeWidth: 2),
                            ),
                          )
                        : Text(
                            curPrice.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                      child: _buildField('QUANTITY', _quantityController)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField('LIMIT PRICE', _limitPriceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildField('TRAIL STOP GAP (\$)', _trailGapController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ORDER COST',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        orderCostFormatted,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.tealAccent),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final order = buildOrderJson();
                      final prettyJson =
                          const JsonEncoder.withIndent('  ').convert(order);

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF132F4C),
                          title: const Text('Order JSON',
                              style: TextStyle(color: Colors.white)),
                          content: SingleChildScrollView(
                            child: Text(
                              prettyJson,
                              style: const TextStyle(
                                color: Colors.tealAccent,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('CLOSE',
                                  style: TextStyle(color: Colors.white70)),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                final accountHash =
                                    await SchwabApiService.fetchAccountHash();
                                if (!context.mounted) return;
                                if (accountHash == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Failed to retrieve account — check logs')),
                                  );
                                  return;
                                }
                                final success = await SchwabApiService.placeOrder(
                                    accountHash, buildOrderJson());
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Order placed: ${_quantityController.text} shares of ${_tickerController.text} @ ${_limitPriceController.text}'
                                          : 'Order failed — check logs',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('CONFIRM',
                                  style: TextStyle(
                                      color: Colors.tealAccent,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('PLACE ORDER',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
