import 'package:da_minha_conta/model/categoria.dart';
import 'package:da_minha_conta/model/transacao.dart';

class Despesa {
  final int id;
  final Transacao transacao;
  final Categoria categoria;

  Despesa({
    required this.id,
    required this.transacao,
    required this.categoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transacao': transacao.id,
      'categoria': categoria.id,
    };
  }

  @override
  String toString() {
    return 'Despesa{id: $id, transacao: ${transacao.toString()}, categoria: ${categoria.toString()}}';
  }
}
