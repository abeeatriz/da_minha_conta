import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/conta.dart';

class ContaDAO {
  final DatabaseHelper _databaseHelper;

  ContaDAO(this._databaseHelper);


  Future<int> insertConta(Conta conta) async {
    final db = await _databaseHelper.database;
    return await db.insert('conta', conta.toMap());
  }

  Future<List<Conta>> getContas() async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query('conta');

    return List.generate(maps.length, (index) {
      return Conta(
        id: maps[index]['id'],
        saldo: maps[index]['saldo'],
        banco: maps[index]['banco'],
        descricao: maps[index]['descricao'],
      );
    });
  }

  Future<Conta?> getConta(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conta',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Conta(
        id: maps.first['id'],
        saldo: maps.first['saldo'],
        banco: maps.first['banco'],
        descricao: maps.first['descricao'],
      );
    }

    return null;
  }

  Future<int> updateConta(Conta conta) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'conta',
      conta.toMap(),
      where: 'id = ?',
      whereArgs: [conta.id],
    );
  }

  Future<int> deleteConta(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'conta',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
