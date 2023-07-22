import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/model/despesa.dart';

class DespesaConta {
  final Despesa despesa;
  final Conta conta;

  DespesaConta({
    required this.despesa,
    required this.conta,
  });

  Map<String, dynamic> toMap() {
    return {
      'despesa': despesa.id,
      'conta': conta.id,
    };
  }

  @override
  String toString() {
    return 'DespesaConta{despesa: ${despesa.toString()}, conta: ${conta.toString()}}';
  }
}
