import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/conta.dart';
import 'package:flutter/material.dart';

class ListarContas extends StatefulWidget {

  const ListarContas({Key? key}) : super(key: key);

  @override
  ListarContasState createState() => ListarContasState();
}

class ListarContasState extends State<ListarContas> {
  List<Conta> _contas = [];

  @override
  void initState() {
    super.initState();
    getContas();
  }

  Future<void> getContas() async {
    final List<Conta> contas = await ContaDAO(DatabaseHelper()).getContas();
    setState(() {
      _contas = contas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contas Cadastradas'),
      ),
      body: ListView.builder(
        itemCount: _contas.length,
        itemBuilder: (context, index) {
          final conta = _contas[index];
          final saldo = conta.saldo;
          final descricao = conta.descricao;

          return ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(descricao),
            subtitle: Text('Saldo: R\$ $saldo'),
          );
        },
      ),
    );
  }
}
