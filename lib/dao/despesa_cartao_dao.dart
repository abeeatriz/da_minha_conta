import 'package:da_minha_conta/dao/cartao_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/despesa_dao.dart';
import 'package:da_minha_conta/model/cartao.dart';
import 'package:da_minha_conta/model/despesa.dart';
import 'package:da_minha_conta/model/despesaCartao.dart';

class DespesaCartaoDAO {
  final DatabaseHelper _databaseHelper;
  final DespesaDAO _despesaDAO;
  final CartaoDAO _cartaoDAO;

  DespesaCartaoDAO(this._databaseHelper, this._despesaDAO, this._cartaoDAO);

  Future<int> insertDespesaCartao(DespesaCartao despesaCartao) async {
    final db = await _databaseHelper.database;

    final despesaId = await _despesaDAO.inserirDespesa(despesaCartao.despesa);
    despesaCartao.despesa.id = despesaId;

    return await db.insert('despesa_cartao', despesaCartao.toMap());
  }

  Future<DespesaCartao?> getDespesaCartao(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'despesa_cartao',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      Map<String, dynamic> map = maps.first;

      Despesa despesa = await getDespesa(map);
      Cartao cartao = await getCartao(map);

      return DespesaCartao(
        despesa: despesa,
        cartao: cartao,
      );
    }

    return null;
  }

  Future<Cartao> getCartao(Map<String, dynamic> map) async {
    Cartao? cartao;
    var cartaoId = map['cartao'];
    if (cartaoId != null) {
      cartao = await _cartaoDAO.getCartao(cartaoId);
    }
    return cartao!;
  }

  Future<Despesa> getDespesa(Map<String, dynamic> map) async {
    Despesa? despesa;
    var despesaId = map['despesa'];
    if (despesaId != null) {
      despesa = await _despesaDAO.getDespesa(despesaId);
    }
    return despesa!;
  }

  Future<List<DespesaCartao>> getDespesasCartao() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('despesa_cartao');

    List<DespesaCartao> despesasCartoes = [];

    for (var map in maps) {
      Despesa despesa = await getDespesa(map);
      Cartao cartao = await getCartao(map);

      DespesaCartao despesaCartao = DespesaCartao(
        despesa: despesa,
        cartao: cartao,
      );

      despesasCartoes.add(despesaCartao);
    }

    return despesasCartoes;
  }

  Future<int> updateDespesaCartao(DespesaCartao despesaCartao) async {
    final db = await _databaseHelper.database;

    final despesaId = await _despesaDAO.atualizarDespesa(despesaCartao.despesa);

    return await db.update(
      'despesa_cartao',
      despesaCartao.toMap(),
      where: 'despesa = ?',
      whereArgs: [despesaId],
    );
  }

  Future<int> deleteDespesaCartao(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'despesa',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
