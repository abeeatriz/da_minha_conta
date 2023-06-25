import 'package:da_minha_conta/model/conta.dart';

class Cartao {
  final int? id;
  final String descricao;
  final double limite;
  final DateTime dataVencimento;
  final Conta? conta;

  const Cartao(
      {this.id,
      required this.descricao,
      required this.limite,
      required this.dataVencimento,
      this.conta});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'limite': limite,
      'dataVencimento': dataVencimento,
      'conta': conta
    };
  }

  @override
  String toString() {
    return 'Cartao{id: $id, limite: $limite, descricao: $descricao, dataVencimento: $dataVencimento, conta: $conta}';
  }
}
