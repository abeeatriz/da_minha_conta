import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/categoria.dart';

class CategoriaDAO {
  final DatabaseHelper _databaseHelper;

  CategoriaDAO(this._databaseHelper);

  Future<int> inserirCategoria(Categoria categoria) async {
    final db = await _databaseHelper.database;
    final int id = await db.insert('categoria', categoria.toMap());
    return id;
  }

  Future<int> atualizarCategoria(Categoria categoria) async {
    final db = await _databaseHelper.database;
    final int linhasAfetadas = await db.update(
      'categoria',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
    return linhasAfetadas;
  }

  Future<int> excluirCategoria(int categoriaId) async {
    final db = await _databaseHelper.database;
    final int linhasAfetadas = await db.delete(
      'categoria',
      where: 'id = ?',
      whereArgs: [categoriaId],
    );
    return linhasAfetadas;
  }

  Future<Categoria?> getCategoria(int categoriaId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categoria',
      where: 'id = ?',
      whereArgs: [categoriaId],
    );

    if (maps.isNotEmpty) {
      return Categoria(
        id: maps[0]['id'],
        descricao: maps[0]['descricao'],
      );
    }

    return null;
  }

  Future<List<Categoria>> getCategorias() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categoria');

    return List.generate(maps.length, (index) {
      return Categoria(
        id: maps[index]['id'],
        descricao: maps[index]['descricao'],
      );
    });
  }
}
