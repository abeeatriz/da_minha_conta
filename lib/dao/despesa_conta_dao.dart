import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/despesa_dao.dart';
import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/model/depesaConta.dart';
import 'package:da_minha_conta/model/despesa.dart';

class DespesaContaDAO {
  final DatabaseHelper _databaseHelper;
  final DespesaDAO _despesaDAO;
  final ContaDAO _contaDAO;

  DespesaContaDAO(this._databaseHelper, this._despesaDAO, this._contaDAO);

  Future<int> insertDespesaConta(DespesaConta despesaConta) async {
    final db = await _databaseHelper.database;

    final despesaId = await _despesaDAO.inserirDespesa(despesaConta.despesa);
    despesaConta.despesa.id = despesaId;

    return await db.insert('despesa_conta', despesaConta.toMap());
  }

  Future<List<DespesaConta>> getDespesasConta() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('despesa_conta');

    List<DespesaConta> despesasContas = [];
    for (var map in maps) {
      Despesa despesa = await getDespesa(map);
      Conta conta = await getConta(map);

      DespesaConta despesaConta = DespesaConta(
        despesa: despesa,
        conta: conta,
      );

      despesasContas.add(despesaConta);
    }

    return despesasContas;
  }

  Future<DespesaConta?> getDespesaConta(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'despesa_conta',
      where: 'despesa = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      Map<String, dynamic> map = maps.first;

      Despesa despesa = await getDespesa(map);
      Conta conta = await getConta(map);

      return DespesaConta(
        despesa: despesa,
        conta: conta,
      );
    }

    return null;
  }

  Future<Conta> getConta(Map<String, dynamic> map) async {
    Conta? conta;
    var contaId = map['conta'];
    if (contaId != null) {
      conta = await _contaDAO.getConta(contaId);
    }
    return conta!;
  }

  Future<Despesa> getDespesa(Map<String, dynamic> map) async {
    Despesa? despesa;
    var despesaId = map['despesa'];
    if (despesaId != null) {
      despesa = await _despesaDAO.getDespesa(despesaId);
    }
    return despesa!;
  }

  Future<int> updateDespesaConta(DespesaConta despesaConta) async {
    final db = await _databaseHelper.database;

    final despesaId = await _despesaDAO.atualizarDespesa(despesaConta.despesa);

    return await db.update(
      'despesa_conta',
      despesaConta.toMap(),
      where: 'despesa = ?',
      whereArgs: [despesaId],
    );
  }

  Future<int> deleteDespesaConta(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'despesa_conta',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
