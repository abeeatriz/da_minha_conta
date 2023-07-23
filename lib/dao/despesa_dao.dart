import 'package:da_minha_conta/dao/categoria_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/transacao_dao.dart';
import 'package:da_minha_conta/model/categoria.dart';
import 'package:da_minha_conta/model/despesa.dart';
import 'package:da_minha_conta/model/transacao.dart';

class DespesaDAO {
  final DatabaseHelper _databaseHelper;
  final TransacaoDAO _transacaoDAO;
  final CategoriaDAO _categoriaDAO;

  DespesaDAO(this._databaseHelper, this._transacaoDAO, this._categoriaDAO);

  Future<int> inserirDespesa(Despesa despesa) async {
    final db = await _databaseHelper.database;

    final transacaoId = await _transacaoDAO.inserirTransacao(despesa.transacao);
    despesa.transacao.id = transacaoId;

    final int id = await db.insert('despesa', despesa.toMap());
    return id;
  }

  Future<int> atualizarDespesa(Despesa despesa) async {
    final db = await _databaseHelper.database;

    final transacaoId = await _transacaoDAO.atualizarTransacao(despesa.transacao);

    final int linhasAfetadas = await db.update(
      'despesa',
      despesa.toMap(),
      where: 'transacao = ?',
      whereArgs: [transacaoId],
    );
    return linhasAfetadas;
  }

  Future<int> excluirDespesa(int despesaId) async {
    final db = await _databaseHelper.database;
    final int linhasAfetadas = await db.delete(
      'despesa',
      where: 'id = ?',
      whereArgs: [despesaId],
    );
    return linhasAfetadas;
  }

  Future<Despesa?> getDespesa(int despesaId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'despesa',
      where: 'id = ?',
      whereArgs: [despesaId],
    );

    if (maps.isNotEmpty) {
      return Despesa(
        id: maps[0]['id'],
        transacao: (await _transacaoDAO.getTransacao(maps[0]['transacao']))!,
        categoria: (await _categoriaDAO.getCategoria(maps[0]['categoria']))!,
      );
    }

    return null;
  }

  Future<List<Despesa>> getDespesas() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('despesa');

    List<Despesa> despesas = [];

    for (var map in maps) {
      Despesa despesa = Despesa(
        id: map['id'],
        transacao: (await _transacaoDAO.getTransacao(map['transacao']))!,
        categoria: (await _categoriaDAO.getCategoria(map['categoria']))!,
      );
      despesas.add(despesa);
    }

    return despesas;
  }

  // Função para obter as despesas do banco de dados de um determinado mês
  Future<List<Despesa>> getDespesasPorMes(int month, int year) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT d.* 
    FROM despesa d 
    INNER JOIN transacao t ON d.transacao = t.id
    WHERE strftime('%m', t.data) = ? AND strftime('%Y', t.data) = ?
  ''', [month.toString().padLeft(2, '0'), year.toString()]);

    List<Despesa> despesas = [];

    for (var map in maps) {
      final despesaId = map['id'];
      final transacaoId = map['transacao'];
      Transacao? transacao = await _transacaoDAO.getTransacao(transacaoId);
      final categoriaId = map['categoria'];
      Categoria? categoria = await _categoriaDAO.getCategoria(categoriaId);

      if (transacao != null && categoria != null) {
        Despesa despesa = Despesa(id: despesaId, transacao: transacao, categoria: categoria);
        despesas.add(despesa);
      }
    }

    return despesas;
  }
}
