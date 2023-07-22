import 'package:da_minha_conta/model/cartao.dart';
import 'package:da_minha_conta/model/despesa.dart';

class DespesaCartao {
  final Despesa despesa;
  final Cartao cartao;

  DespesaCartao({
    required this.despesa,
    required this.cartao,
  });

  Map<String, dynamic> toMap() {
    return {
      'despesa': despesa.id,
      'cartao': cartao.id,
    };
  }

  @override
  String toString() {
    return 'DespesaCartao{despesa: $despesa, cartao: $cartao}';
  }
}
