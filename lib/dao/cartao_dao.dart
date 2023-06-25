import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/model/cartao.dart';
import 'package:da_minha_conta/model/conta.dart';

class CartaoDAO {
  final DatabaseHelper _databaseHelper;
  final ContaDAO _contaDAO;

  CartaoDAO(this._databaseHelper, this._contaDAO);

  Future<int> insertCartao(Cartao cartao) async {
    final db = await _databaseHelper.database;
    return await db.insert('cartao', cartao.toMap());
  }

  Future<List<Cartao>> getCartoes() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cartao');

    List<Cartao> cartoes = [];

    for (var map in maps) {
      Conta? conta = await getContaById(map);

      Cartao cartao = Cartao(
        id: map['id'],
        descricao: map['descricao'],
        limite: map['limite'],
        dataVencimento: DateTime.parse(map['data_vencimento']),
        conta: conta,
      );
      cartoes.add(cartao);
    }

    return cartoes;
  }

  Future<Conta?> getContaById(Map<String, dynamic> map) async {
    Conta? conta;
    var contaId = map['conta'];
    if (contaId != null) {
      conta = await _contaDAO.getConta(contaId);
    }
    return conta;
  }

  Future<Cartao?> getCartao(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cartao',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      Conta? conta = await getContaById(maps.first);

      return Cartao(
        id: maps.first['id'],
        descricao: maps.first['descricao'],
        limite: maps.first['limite'],
        dataVencimento: DateTime.parse(maps.first['data_vencimento']),
        conta: conta,
      );
    }

    return null;
  }

  Future<int> updateCartao(Cartao cartao) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'cartao',
      cartao.toMap(),
      where: 'id = ?',
      whereArgs: [cartao.id],
    );
  }

  Future<int> deleteCartao(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'cartao',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
