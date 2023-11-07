import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MeuAppFinancas());
}

class MeuAppFinancas extends StatefulWidget {
  @override
  _MeuAppFinancasState createState() => _MeuAppFinancasState();
}

class _MeuAppFinancasState extends State<MeuAppFinancas> {
  Map<String, dynamic> currencies = {};
  Map<String, dynamic> bitcoinCurrencies = {};
  Map<String, dynamic> stockData = {};

  @override
  void initState() {
    super.initState();
    fetchCurrencies().then((data) {
      setState(() {
        currencies = data;
      });
    });
    fetchBitcoinCurrencies().then((data) {
      setState(() {
        bitcoinCurrencies = data;
      });
    });
    fetchStockData().then((data) {
      setState(() {
        stockData = data;
      });
    });
  }

  Future<Map<String, dynamic>> fetchCurrencies() async {
    final response = await http.get(Uri.parse(
        'https://api.hgbrasil.com/finance?key=0c42162b&format=json-cors'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'Dólar': {
          'valor': data['results']['currencies']['USD']['buy'],
          'variação': data['results']['currencies']['USD']['variation'],
        },
        'Euro': {
          'valor': data['results']['currencies']['EUR']['buy'],
          'variação': data['results']['currencies']['EUR']['variation'],
        },
        'Peso': {
          'valor': data['results']['currencies']['ARS']['buy'],
          'variação': data['results']['currencies']['ARS']['variation'],
        },
        'Yen': {
          'valor': data['results']['currencies']['JPY']['buy'],
          'variação': data['results']['currencies']['JPY']['variation'],
        },
      };
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  Future<Map<String, dynamic>> fetchBitcoinCurrencies() async {
    final response = await http.get(Uri.parse(
        'https://api.hgbrasil.com/finance?key=0c42162b&format=json-cors'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'Blockchain': {
          'valor': data['results']['bitcoin']['blockchain_info']['buy'],
          'variação': data['results']['bitcoin']['blockchain_info']
              ['variation'],
        },
        'Coinbase': {
          'valor': data['results']['bitcoin']['coinbase']['last'],
          'variação': data['results']['bitcoin']['coinbase']['variation'],
        },
        'BitStamp': {
          'valor': data['results']['bitcoin']['bitstamp']['buy'],
          'variação': data['results']['bitcoin']['bitstamp']['variation'],
        },
        'FoxBit': {
          'valor': data['results']['bitcoin']['foxbit']['last'],
          'variação': data['results']['bitcoin']['foxbit']['variation'],
        },
      };
    } else {
      throw Exception('Failed to load Bitcoin currencies');
    }
  }

  Future<Map<String, dynamic>> fetchStockData() async {
    final response = await http.get(Uri.parse(
        'https://api.hgbrasil.com/finance?key=0c42162b&format=json-cors'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'IBOVESPA': {
          'valor': data['results']['stocks']['IBOVESPA']['points'],
          'variação': data['results']['stocks']['IBOVESPA']['variation'],
        },
        'NASDAQ': {
          'valor': data['results']['stocks']['NASDAQ']['points'],
          'variação': data['results']['stocks']['NASDAQ']['variation'],
        },
        'IFIX': {
          'valor': data['results']['stocks']['IFIX']['points'],
          'variação': data['results']['stocks']['IFIX']['variation'],
        },
        'DOWJONES': {
          'valor': data['results']['stocks']['DOWJONES']['points'],
          'variação': data['results']['stocks']['DOWJONES']['variation'],
        },
        'CAC': {
          'valor': data['results']['stocks']['CAC']['points'],
          'variação': data['results']['stocks']['CAC']['variation'],
        },
        'NIKKEI': {
          'valor': data['results']['stocks']['NIKKEI']['points'],
          'variação': data['results']['stocks']['NIKKEI']['variation'],
        },
      };
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Finanças de Hoje'),
          backgroundColor: Colors.green[900],
        ),
        body: _buildPage(_currentIndex),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green[900],
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Moedas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Ações',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              label: 'BitCoin',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return MoedasPage(currencies);
      case 1:
        return AcoesPage(stockData);
      case 2:
        return BitCoinPage(bitcoinCurrencies);
      default:
        return Container();
    }
  }
}

class MoedasPage extends StatelessWidget {
  final Map<String, dynamic> currencies;

  MoedasPage(this.currencies);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moedas'),
        backgroundColor: Colors.green[900],
      ),
      body: Center(
        child: Column(
          children: [
            _buildCurrency("Dólar", currencies['Dólar']),
            _buildCurrency("Euro", currencies['Euro']),
            _buildCurrency("Peso", currencies['Peso']),
            _buildCurrency("Yen", currencies['Yen']),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[900],
      ),
    );
  }

  Widget _buildCurrency(String name, Map<String, dynamic> data) {
    double value = data['valor'];
    double variation = data['variação'];

    Color textColor = variation >= 0 ? Colors.blue : Colors.red;
    Color backgroundColor = variation >= 0 ? Colors.blue : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$name: ${value.toStringAsFixed(4)}',
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              '${variation.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class AcoesPage extends StatelessWidget {
  final Map<String, dynamic> stockData;

  AcoesPage(this.stockData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ações'),
        backgroundColor: Colors.green[900],
      ),
      body: Center(
        child: Column(
          children: stockData.entries.map((entry) {
            String name = entry.key;
            double value = entry.value['valor'];
            double variation = entry.value['variação'];

            Color textColor = variation >= 0 ? Colors.blue : Colors.red;
            Color backgroundColor = variation >= 0 ? Colors.blue : Colors.red;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$name: ${value.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${variation.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[900],
      ),
    );
  }
}

class BitCoinPage extends StatelessWidget {
  final Map<String, dynamic> bitcoinCurrencies;

  BitCoinPage(this.bitcoinCurrencies);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BitCoin'),
        backgroundColor: Colors.green[900],
      ),
      body: Center(
        child: Column(
          children: bitcoinCurrencies.entries.map((entry) {
            String name = entry.key;
            double value = entry.value['valor'];
            double variation = entry.value['variação'];

            Color textColor = variation >= 0 ? Colors.blue : Colors.red;
            Color backgroundColor = variation >= 0 ? Colors.blue : Colors.red;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$name: ${value.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      '${variation.toStringAsFixed(3)}',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green[900],
      ),
    );
  }
}
