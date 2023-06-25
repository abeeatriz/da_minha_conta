class Transacao {
  int? id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String recorrencia;
  final String? imagem;

  Transacao({
    this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.recorrencia,
    this.imagem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String(),
      'recorrencia': recorrencia,
      'imagem': imagem,
    };
  }

  @override
  String toString() {
    return 'Transacao{id: $id, descricao: $descricao, valor: $valor, data: $data, recorrencia: $recorrencia, imagem: ${imagem != null ? 'presente' : 'ausente'}}';
  }
}
