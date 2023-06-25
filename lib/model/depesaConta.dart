import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/model/despesa.dart';

class DespesaConta {
  final int id;
  final Despesa despesa;
  final Conta conta;

  DespesaConta({
    required this.id,
    required this.despesa,
    required this.conta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'despesa': despesa.id,
      'conta': conta.id,
    };
  }

  @override
  String toString() {
    return 'DespesaConta{id: $id, despesa: ${despesa.toString()}, conta: ${conta.toString()}}';
  }
}
