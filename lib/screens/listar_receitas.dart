import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/receita_dao.dart';
import 'package:da_minha_conta/dao/transacao_dao.dart';
import 'package:da_minha_conta/model/receita.dart';
import 'package:flutter/material.dart';

class ReceitasScreen extends StatefulWidget {
  const ReceitasScreen({Key? key}) : super(key: key);

  @override
  ReceitasScreenState createState() => ReceitasScreenState();
}

class ReceitasScreenState extends State<ReceitasScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late TransacaoDAO _transacaoDAO;
  late ContaDAO _contaDAO;
  late ReceitaDAO _receitaDAO;

  List<Receita> receitas = [];

  double calcularTotalReceitas() {
    double total = 0;
    for (var receita in receitas) {
      total += receita.transacao.valor;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _transacaoDAO = TransacaoDAO(_databaseHelper);
    _contaDAO = ContaDAO(_databaseHelper);
    _receitaDAO = ReceitaDAO(_databaseHelper, _transacaoDAO, _contaDAO);

    carregarReceitas();
  }

  Future<void> carregarReceitas() async {
    List<Receita> receitasCarregadas = await _receitaDAO.getReceitas();
    setState(() {
      receitas = receitasCarregadas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total de Receitas: R\$ ${calcularTotalReceitas().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: receitas.length,
              itemBuilder: (context, index) {
                Receita receita = receitas[index];
                return ListTile(
                  title: Text(receita.transacao.descricao),
                  subtitle: Text('Data: ${receita.transacao.data.toString()}'),
                  trailing: Text('R\$ ${receita.transacao.valor.toStringAsFixed(2)}'),
                  onTap: () {
                    // Navegar para a tela de edição da receita específica
                    // Passar a receita como argumento se necessário
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarReceitaScreen(receita),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EditarReceitaScreen extends StatelessWidget {
  const EditarReceitaScreen(this.receita, {Key? key}) : super(key: key);

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Receita'),
      ),
      body: Container(
          // Implemente a tela de edição da receita aqui
          ),
    );
  }
}
