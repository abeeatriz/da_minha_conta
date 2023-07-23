import 'package:da_minha_conta/components/month_selector.dart';
import 'package:da_minha_conta/dao/categoria_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/despesa_dao.dart';
import 'package:da_minha_conta/dao/transacao_dao.dart';
import 'package:da_minha_conta/model/despesa.dart';
import 'package:da_minha_conta/screens/despesas/editar_despesa.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DespesasScreen extends StatefulWidget {
  const DespesasScreen({Key? key}) : super(key: key);

  @override
  DespesasScreenState createState() => DespesasScreenState();
}

class DespesasScreenState extends State<DespesasScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  late TransacaoDAO _transacaoDAO;
  late CategoriaDAO _categoriaDAO;
  late DespesaDAO _despesaDAO;

  List<Despesa> despesas = [];
  late DateTime selectedMonth;

  double calcularTotalDespesas() {
    double total = 0;
    for (var despesa in despesas) {
      total += despesa.transacao.valor;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _transacaoDAO = TransacaoDAO(_db);
    _categoriaDAO = CategoriaDAO(_db);
    _despesaDAO = DespesaDAO(_db, _transacaoDAO, _categoriaDAO);

    selectedMonth = DateTime.now();
    carregarDespesas();
  }

  Future<void> carregarDespesas() async {
    List<Despesa> despesasCarregadas = await _despesaDAO.getDespesasPorMes(selectedMonth.month, selectedMonth.year);
    setState(() {
      despesas = despesasCarregadas;
    });
  }

  void goToPreviousMonth(DateTime previousMonth) {
    setState(() {
      selectedMonth = previousMonth;
    });
    carregarDespesas();
  }

  void goToCurrentMonth() {
    setState(() {
      selectedMonth = DateTime.now();
    });
    carregarDespesas();
  }

  void goToNextMonth(DateTime nextMonth) {
    setState(() {
      selectedMonth = nextMonth;
    });
    carregarDespesas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total de Despesas: R\$ ${calcularTotalDespesas().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          MonthSelector(
            selectedMonth: selectedMonth,
            onPreviousMonthPressed: goToPreviousMonth,
            onCurrentMonthPressed: goToCurrentMonth,
            onNextMonthPressed: goToNextMonth,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: despesas.length,
              itemBuilder: (context, index) {
                Despesa despesa = despesas[index];
                return ListTile(
                  title: Text(despesa.transacao.descricao),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(despesa.transacao.data)),
                  trailing: Text('R\$ ${despesa.transacao.valor.toStringAsFixed(2)}'),
                  onTap: () {
                    // Navegar para a tela de edição da despesa específica
                    // Passar a despesa como argumento se necessário
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarDespesa(despesa),
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
