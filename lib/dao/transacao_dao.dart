import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/transacao.dart';

class TransacaoDAO {
  final DatabaseHelper _databaseHelper;

  TransacaoDAO(this._databaseHelper);

  Future<int> inserirTransacao(Transacao transacao) async {
    final db = await _databaseHelper.database;
    final int id = await db.insert('transacao', transacao.toMap());
    return id;
  }

  Future<int> atualizarTransacao(Transacao transacao) async {
    final db = await _databaseHelper.database;
    final int linhasAfetadas = await db.update(
      'transacao',
      transacao.toMap(),
      where: 'id = ?',
      whereArgs: [transacao.id],
    );
    return linhasAfetadas;
  }

  Future<int> excluirTransacao(int transacaoId) async {
    final db = await _databaseHelper.database;
    final int linhasAfetadas = await db.delete(
      'transacao',
      where: 'id = ?',
      whereArgs: [transacaoId],
    );
    return linhasAfetadas;
  }

  Future<Transacao?> getTransacao(int transacaoId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transacao',
      where: 'id = ?',
      whereArgs: [transacaoId],
    );

    if (maps.isNotEmpty) {
      return Transacao(
        id: maps[0]['id'],
        descricao: maps[0]['descricao'],
        valor: maps[0]['valor'],
        data: DateTime.parse(maps[0]['data']),
        recorrencia: maps[0]['recorrencia'],
        imagem: maps[0]['imagem'],
      );
    }

    return null;
  }

  Future<List<Transacao>> getTransacoes() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('transacao');

    return List.generate(maps.length, (index) {
      return Transacao(
        id: maps[index]['id'],
        descricao: maps[index]['descricao'],
        valor: maps[index]['valor'],
        data: DateTime.parse(maps[index]['data']),
        recorrencia: maps[index]['recorrencia'],
        imagem: maps[index]['imagem'],
      );
    });
  }
}
