import 'dart:convert';
import 'dart:io';

import 'package:da_minha_conta/services/ExchangeRate.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Currency {
  final String code;
  final String name;

  Currency({required this.code, required this.name});
}

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _inputController = MoneyMaskedTextController(
    leftSymbol: '',
    decimalSeparator: ',',
  );
  double _convertedValue = 0.0;
  Currency? _selectedCurrency1;
  Currency? _selectedCurrency2;
  List<Currency> _currencies = [];
  ExchangeRate? _rate;

  @override
  void initState() {
    HttpOverrides.global = MyHttpOverrides();
    super.initState();
    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    final response = await http.get(Uri.parse('https://economia.awesomeapi.com.br/json/available/uniq'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      List<Currency> currencies = [];

      data.forEach((key, value) {
        Currency currency = Currency(code: key, name: value);
        currencies.add(currency);
      });

      currencies.sort((a, b) => a.name.compareTo(b.name));

      setState(() {
        _currencies = currencies;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Você está offline!'),
            content: const Text('Para utilizar essa funcionalidade, conecte-se a internet!'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: const Text('FECHAR'),
              ),
            ],
          );
        },
      );
    }
  }

  void convertCurrency() async {
    if (_selectedCurrency1 == null || _selectedCurrency2 == null) {
      return;
    }

    if (_selectedCurrency1 == _selectedCurrency2) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Conversão inválida'),
            content: const Text('As moedas selecionadas são idênticas.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_rate?.name != '${_selectedCurrency1?.name}${_selectedCurrency2?.name}') {
      _rate = await CurrencyConverter.fetchExchangeRate(_selectedCurrency1!.code, _selectedCurrency2!.code);
    }

    // Perform currency conversion
    final inputValue = _inputController.numberValue;
    double bid = _rate?.bid ?? 0;
    double convertedValue = bid * inputValue;

    setState(() {
      _convertedValue = convertedValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moeda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Currency>(
              value: _selectedCurrency1,
              onChanged: (newValue) {
                convertCurrency();
                setState(() {
                  _selectedCurrency1 = newValue;
                });
              },
              items: _currencies.map((currency) {
                return DropdownMenuItem<Currency>(
                  value: currency,
                  child: Text(currency.name),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Converter de',
              ),
            ),
            DropdownButtonFormField<Currency>(
              value: _selectedCurrency2,
              onChanged: (newValue) {
                convertCurrency();
                setState(() {
                  _selectedCurrency2 = newValue;
                });
              },
              items: _currencies.map((currency) {
                return DropdownMenuItem<Currency>(
                  value: currency,
                  child: Text(currency.name),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Para',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: _selectedCurrency1?.code ?? 'Valor',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => convertCurrency(),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedCurrency2 != null ? '${_selectedCurrency2?.code} ${_convertedValue.toStringAsFixed(2)}' : '',
              style: const TextStyle(fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
    ..badCertificateCallback =
     (X509Certificate cert, String host, int port) => true;
  }
}
