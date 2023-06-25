import 'package:da_minha_conta/model/categoria.dart';

class Orcamento {
  final int id;
  final String descricao;
  final double valor;
  final Categoria? categoria;

  Orcamento({
    required this.id,
    required this.descricao,
    required this.valor,
    this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'categoria': categoria?.id,
    };
  }

  @override
  String toString() {
    return 'Orcamento{id: $id, descricao: $descricao, valor: $valor, categoria: $categoria}';
  }
}
