import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeRate {
  final String name;
  final double bid;

  ExchangeRate({required this.name, required this.bid});
}

class CurrencyConverter {
  static Future<ExchangeRate?> fetchExchangeRate(String? inputCurrency, String? outputCurrency) async {
    if (inputCurrency == null || outputCurrency == null) {
      return null;
    }

    final response = await http
        .get(Uri.parse('https://api.invertexto.com/v1/currency/${inputCurrency}_$outputCurrency?token=3928|dAhqdJsqeM3xiRW3Wg5v0l250sU9Ai9d'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final price = data['${inputCurrency}_$outputCurrency']['price'];
      return ExchangeRate(name: '$inputCurrency$outputCurrency', bid: price as double);
    } else {
      throw Exception('Failed to fetch exchange rate');
    }
  }
}
