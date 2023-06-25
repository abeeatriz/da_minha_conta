import 'package:da_minha_conta/dao/categoria_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/categoria.dart';
import 'package:da_minha_conta/model/orcamento.dart';

class OrcamentoDAO {
  final DatabaseHelper _databaseHelper;
  final CategoriaDAO _categoriaDAO;

  OrcamentoDAO(this._databaseHelper, this._categoriaDAO);

  Future<int> inserirOrcamento(Orcamento orcamento) async {
    final db = await _databaseHelper.database;
    final int id = await db.insert('orcamento', orcamento.toMap());
    return id;
  }

  Future<int> atualizarOrcamento(Orcamento orcamento) async {
    final db = await _databaseHelper.database;
    final int linhasAfetadas = await db.update(
      'orcamento',
      orcamento.toMap(),
      where: 'id = ?',
      whereArgs: [orcamento.id],
    );
    return linhasAfetadas;
  }

  Future<int> excluirOrcamento(int orcamentoId) async {
    final db = await _databaseHelper.database;
    final int linhasAfetadas = await db.delete(
      'orcamento',
      where: 'id = ?',
      whereArgs: [orcamentoId],
    );
    return linhasAfetadas;
  }

  Future<Orcamento?> getOrcamento(int orcamentoId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orcamento',
      where: 'id = ?',
      whereArgs: [orcamentoId],
    );

    if (maps.isNotEmpty) {
      return Orcamento(
        id: maps[0]['id'],
        descricao: maps[0]['descricao'],
        valor: maps[0]['valor'],
        categoria: await _categoriaDAO.getCategoria(maps[0]['categoria']),
      );
    }

    return null;
  }

Future<List<Orcamento>> getOrcamentos() async {
  final db = await _databaseHelper.database;
  final List<Map<String, dynamic>> maps = await db.query('orcamento');

  List<Orcamento> orcamentos = [];

  for (var map in maps) {
    Categoria? categoria;
    if (map['categoria'] != null) {
      categoria = await _categoriaDAO.getCategoria(map['categoria']);
    }
    Orcamento orcamento = Orcamento(
      id: map['id'],
      descricao: map['descricao'],
      valor: map['valor'],
      categoria: categoria,
    );
    orcamentos.add(orcamento);
  }

  return orcamentos;
}

}
