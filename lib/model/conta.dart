class Conta {
  final int? id;
  final double saldo;
  final String? banco;
  final String descricao;

  const Conta({
    this.id,
    required this.saldo,
    this.banco,
    required this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saldo': saldo,
      'banco': banco,
      'descricao': descricao,
    };
  }

  @override
  String toString() {
    return 'Conta{id: $id, saldo: $saldo, banco: $banco, descricao: $descricao}';
  }
}
