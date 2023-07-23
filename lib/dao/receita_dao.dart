import 'package:da_minha_conta/dao/conta_dao.dart';
import 'package:da_minha_conta/dao/database_helper.dart';
import 'package:da_minha_conta/dao/transacao_dao.dart';
import 'package:da_minha_conta/model/conta.dart';
import 'package:da_minha_conta/model/receita.dart';
import 'package:da_minha_conta/model/transacao.dart';

class ReceitaDAO {
  final DatabaseHelper _databaseHelper;
  final TransacaoDAO _transacaoDAO;
  final ContaDAO _contaDAO;

  ReceitaDAO(this._databaseHelper, this._transacaoDAO, this._contaDAO);

  // Função para inserir uma nova receita no banco de dados
  Future<int> inserirReceita(Receita receita) async {
    final db = await _databaseHelper.database;

    final transacaoId = await _transacaoDAO.inserirTransacao(receita.transacao);
    receita.transacao.id = transacaoId;

    final int id = await db.insert('receita', receita.toMap());
    return id;
  }

  // Função para atualizar uma receita no banco de dados
  Future<int> atualizarReceita(Receita receita) async {
    final db = await _databaseHelper.database;

    int registrosAlterados = await _transacaoDAO.atualizarTransacao(receita.transacao);

    registrosAlterados += await db.update(
      'receita',
      receita.toMap(),
      where: 'transacao = ?',
      whereArgs: [receita.transacao.id],
    );
    return registrosAlterados;
  }

  // Função para excluir uma receita do banco de dados
  Future<int> excluirReceita(int receitaId) async {
    final db = await _databaseHelper.database;
    final int linhasAfetadas = await db.delete(
      'receita',
      where: 'id = ?',
      whereArgs: [receitaId],
    );
    return linhasAfetadas;
  }

  // Função para obter todas as receitas do banco de dados
  Future<List<Receita>> getReceitas() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('receita');

    List<Receita> receitas = [];

    for (var map in maps) {
      final transacaoId = map['transacao'];
      Transacao? transacao = await _transacaoDAO.getTransacao(transacaoId);
      final contaId = map['conta'];
      Conta? conta = await _contaDAO.getConta(contaId);
      Receita receita = Receita(transacao: transacao!, conta: conta!);
      receitas.add(receita);
    }
    return receitas;
  }

// Função para obter as receitas do banco de dados de um determinado mês
  Future<List<Receita>> getReceitasPorMes(int month, int year) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT r.* 
    FROM receita r 
    INNER JOIN transacao t ON r.transacao = t.id
    WHERE strftime('%m', t.data) = ? AND strftime('%Y', t.data) = ?
  ''', [month.toString().padLeft(2, '0'), year.toString()]);

    List<Receita> receitas = [];

    for (var map in maps) {
      final transacaoId = map['transacao'];
      Transacao? transacao = await _transacaoDAO.getTransacao(transacaoId);
      final contaId = map['conta'];
      Conta? conta = await _contaDAO.getConta(contaId);

      if (transacao != null && conta != null) {
        Receita receita = Receita(transacao: transacao, conta: conta);
        receitas.add(receita);
      }
    }

    return receitas;
  }

  // Função para obter uma receita pelo ID
  Future<Receita?> getReceita(int transacaoId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'receita',
      where: 'transacao = ?',
      whereArgs: [transacaoId],
    );

    if (maps.isNotEmpty) {
      final transacaoId = maps.first['transacao'];
      Transacao? transacao = await _transacaoDAO.getTransacao(transacaoId);
      final contaId = maps.first['conta'];
      Conta? conta = await _contaDAO.getConta(contaId);

      return Receita(
        transacao: transacao!,
        conta: conta!,
      );
    }

    return null;
  }
}
