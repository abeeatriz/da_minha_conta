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
            saldo NOT NULL DOUBLE,
            banco NOT NULL VARCHAR(100),
            descricao NOT NULL VARCHAR(100)
          )
        ''');

        await db.execute('''
          CREATE TABLE cartao (
            id INTEGER PRIMARY KEY,
            descricao NOT NULL VARCHAR(100),
            limite NOT NULL DOUBLE,
            data_vencimento NOT NULL DATE,
            conta INTEGER REFERENCES conta(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE categoria (
            id INTEGER PRIMARY KEY,
            descricao NOT NULL VARCHAR(100)
          )
        ''');

        await db.execute('''
          CREATE TABLE orcamento (
            id INTEGER PRIMARY KEY,
            descricao NOT NULL VARCHAR(100),
            valor NOT NULL DOUBLE,
            categoria NOT NULL INTEGER REFERENCES categoria(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE transacao (
            id INTEGER PRIMARY KEY,
            descricao NOT NULL VARCHAR(100),
            valor NOT NULL DOUBLE,
            data NOT NULL TEXT,
            recorrencia NOT NULL VARCHAR(20),
            imagem TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE receita (
            transacao INTEGER NOT NULL REFERENCES transacao(id) ON DELETE CASCADE,
            conta NOT NULL INTEGER REFERENCES conta(id)
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
