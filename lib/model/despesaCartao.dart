import 'package:da_minha_conta/model/cartao.dart';
import 'package:da_minha_conta/model/despesa.dart';

class DespesaCartao {
  final int id;
  final Despesa despesa;
  final Cartao cartao;

  DespesaCartao({
    required this.id,
    required this.despesa,
    required this.cartao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'despesa': despesa.id,
      'cartao': cartao.id,
    };
  }

  @override
  String toString() {
    return 'DespesaCartao{id: $id, despesa: $despesa, cartao: $cartao}';
  }
}
