class Categoria {
  final int id;
  final String descricao;

  Categoria({
    required this.id,
    required this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }

  @override
  String toString() {
    return 'Categoria{id: $id, descricao: $descricao}';
  }
}
