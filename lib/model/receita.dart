import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/model/transacao.dart';

class Receita {
  final Transacao transacao;
  final Conta conta;

  Receita({
    required this.transacao,
    required this.conta,
  });

  Map<String, dynamic> toMap() {
    return {
      'transacao': transacao.id,
      'conta': conta.id,
    };
  }

  @override
  String toString() {
    return 'Receita{transacao: ${transacao.toString()}, conta: ${conta.toString()}}';
  }
}
