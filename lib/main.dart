import 'package:da_minha_conta/screens/categoria/nova_categoria.dart';
import 'package:da_minha_conta/screens/currency_converter/currency_converter_screen.dart';
import 'package:da_minha_conta/screens/receitas/listar_receitas.dart';
import 'package:da_minha_conta/screens/contas/nova_conta.dart';
import 'package:da_minha_conta/screens/despesas/nova_despesa.dart';
import 'package:da_minha_conta/screens/despesas/nova_despesa_cartao.dart';
import 'package:da_minha_conta/screens/receitas/nova_receita.dart';
import 'package:da_minha_conta/screens/cartoes/novo_cartao.dart';
import 'package:da_minha_conta/screens/contas/listar_contas.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DaMinhaContaApp());
}

class DaMinhaContaApp extends StatelessWidget {
  const DaMinhaContaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Da Minha Conta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Da Minha Conta'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NovaReceita()),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle, size: 48.0, color: Colors.lightGreen),
                  SizedBox(height: 8.0),
                  Text('Nova Receita', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NovaDespesa()),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.remove_circle, size: 48.0, color: Colors.red),
                  SizedBox(height: 8.0),
                  Text('Nova Despesa', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NovaDespesaCartao()),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.credit_card,
                    size: 48.0,
                    color: Colors.red,
                  ),
                  SizedBox(height: 8.0),
                  Text('Nova despesa no Cartão', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NovoCartao()),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.credit_card, size: 48.0),
                  SizedBox(height: 8.0),
                  Text('Novo Cartão', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NovaConta()),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.account_balance, size: 48.0),
                  SizedBox(height: 8.0),
                  Text('Nova Conta', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListarContas()),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.list, size: 48.0),
                  SizedBox(height: 8.0),
                  Text('Minhas Contas', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReceitasScreen()),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.list, size: 48.0),
                  SizedBox(height: 8.0),
                  Text('Receitas', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NovaCategoria()),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.currency_exchange, size: 48.0),
                  SizedBox(height: 8.0),
                  Text('Nova Categoria', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CurrencyConverterScreen()),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.currency_exchange, size: 48.0),
                  SizedBox(height: 8.0),
                  Text('Conversor de Moeda', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
