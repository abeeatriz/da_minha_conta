import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  static const String _databaseName = 'da_minha_conta_database.db';

  DatabaseHelper.internal();

  Future<Database> get database async {
    // _deleteDatabase();
    if (_database != null) {
      return _database!;
    }

    return await initDatabase();
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE conta (
            id INTEGER PRIMARY KEY,
            saldo DOUBLE NOT NULL,
            banco VARCHAR(100) NOT NULL,
            descricao VARCHAR(100) NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE cartao (
            id INTEGER PRIMARY KEY,
            descricao VARCHAR(100) NOT NULL,
            limite DOUBLE NOT NULL,
            data_vencimento DATE NOT NULL,
            conta INTEGER REFERENCES conta(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE categoria (
            id INTEGER PRIMARY KEY,
            descricao VARCHAR(100) NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE orcamento (
            id INTEGER PRIMARY KEY,
            descricao VARCHAR(100) NOT NULL,
            valor DOUBLE NOT NULL,
            categoria INTEGER NOT NULL REFERENCES categoria(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE transacao (
            id INTEGER PRIMARY KEY,
            descricao VARCHAR(100) NOT NULL,
            valor DOUBLE NOT NULL,
            data TEXT NOT NULL,
            recorrencia VARCHAR(20) NOT NULL,
            imagem TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE receita (
            transacao INTEGER NOT NULL REFERENCES transacao(id) ON DELETE CASCADE,
            conta INTEGER NOT NULL REFERENCES conta(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE despesa (
            id INTEGER PRIMARY KEY,
            transacao INTEGER NOT NULL REFERENCES transacao(id) ON DELETE CASCADE,
            categoria INTEGER NOT NULL REFERENCES categoria(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE despesa_conta (
            despesa INTEGER NOT NULL REFERENCES despesa(id) ON DELETE CASCADE,
            conta INTEGER NOT NULL REFERENCES conta(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE despesa_cartao (
            despesa INTEGER NOT NULL REFERENCES despesa(id) ON DELETE CASCADE,
            cartao INTEGER NOT NULL REFERENCES cartao(id)
          )
        ''');

        insertDefaultDataInDB(db);
      },
    );
  }

  Future<void> _deleteDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, _databaseName);
    await deleteDatabase(databasePath);
  }

  void insertDefaultDataInDB(Database db) async {
    Map<String, dynamic> carteira = {"saldo": 0.0, "banco": "Outro", "descricao": "Carteira"};
    await db.insert('conta', carteira);

    Map<String, dynamic> outros = {"descricao": "Outros"};
    await db.insert('categoria', outros);
  }
}
