import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  static const String tableOrcamentos = 'orcamentos';
  static const String tableProdutos = 'produtos';
  static const String tableAnotacoes = 'anotacoes';
  static const int dbVersion = 4;

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'app_database.db'),
      version: dbVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableOrcamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente TEXT NOT NULL,
        data TEXT NOT NULL,
        valor_total REAL DEFAULT 0.0,
        desconto REAL DEFAULT 0.0
      )''');

    await db.execute('''
      CREATE TABLE $tableProdutos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orcamento_id INTEGER NOT NULL,
        nome TEXT NOT NULL,
        preco REAL NOT NULL,
        quantidade INTEGER DEFAULT 1,
        FOREIGN KEY(orcamento_id) 
          REFERENCES $tableOrcamentos(id) 
          ON DELETE CASCADE
      )''');

    await db.execute('''
      CREATE TABLE $tableAnotacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        conteudo TEXT NOT NULL,
        data TEXT NOT NULL
      )''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $tableProdutos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          orcamento_id INTEGER NOT NULL,
          nome TEXT NOT NULL,
          preco REAL NOT NULL,
          quantidade INTEGER DEFAULT 1
        )''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE $tableOrcamentos 
        ADD COLUMN valor_total REAL DEFAULT 0.0
      ''');

      final List<Map<String, dynamic>> orcamentos = List.from(
        await db.query(tableOrcamentos),
      );

      for (final orcamento in orcamentos) {
        final total = await db.rawQuery(
          '''
          SELECT SUM(preco * quantidade) as total 
          FROM $tableProdutos 
          WHERE orcamento_id = ?
        ''',
          [orcamento['id']],
        );

        await db.update(
          tableOrcamentos,
          {'valor_total': total.first['total'] ?? 0.0},
          where: 'id = ?',
          whereArgs: [orcamento['id']],
        );
      }
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE $tableAnotacoes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          conteudo TEXT NOT NULL,
          data TEXT NOT NULL
        )''');

      await db.execute('''
        ALTER TABLE $tableOrcamentos 
        ADD COLUMN desconto REAL DEFAULT 0.0
      ''');

      try {
        await db.execute(
          'ALTER TABLE $tableProdutos RENAME COLUMN descricao TO nome',
        );
        await db.execute(
          'ALTER TABLE $tableProdutos RENAME COLUMN valor TO preco',
        );
        await db.execute(
          'ALTER TABLE $tableProdutos ADD COLUMN quantidade INTEGER DEFAULT 1',
        );
      } catch (e) {
        print('Erro ao modificar tableProdutos: $e');
      }
    }
  }

  Future<int> insertOrcamento(Map<String, dynamic> orcamento) async {
    final db = await database;
    final String data = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    return await db.transaction<int>((txn) async {
      final orcamentoId = await txn.insert(tableOrcamentos, {
        'cliente': orcamento['cliente'].toString().trim(),
        'data': data,
        'valor_total': orcamento['valor_total'],
        'desconto': orcamento['desconto'] ?? 0.0,
      });

      final batch = txn.batch();
      for (final produto in orcamento['produtos']) {
        batch.insert(tableProdutos, {
          'orcamento_id': orcamentoId,
          'nome': produto['nome'].toString().trim(),
          'preco': double.tryParse(produto['preco'].toString()) ?? 0.0,
          'quantidade': produto['quantidade'] ?? 1,
        });
      }
      await batch.commit();

      return orcamentoId;
    });
  }

  Future<List<Map<String, dynamic>>> getOrcamentos() async {
    final db = await database;
    List<Map<String, dynamic>> orcamentos = List.from(
      await db.query(tableOrcamentos, orderBy: 'data DESC'),
    );

    for (int i = 0; i < orcamentos.length; i++) {
      List<Map<String, dynamic>> produtos = List.from(
        await db.query(
          tableProdutos,
          where: 'orcamento_id = ?',
          whereArgs: [orcamentos[i]['id']],
        ),
      );
      orcamentos[i] = {...orcamentos[i], 'produtos': produtos};
    }

    return orcamentos;
  }

  Future<Map<String, dynamic>?> getOrcamentoById(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> orcamentos = await db.query(
      tableOrcamentos,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (orcamentos.isEmpty) {
      return null;
    }

    Map<String, dynamic> orcamento = orcamentos.first;

    List<Map<String, dynamic>> produtos = await db.query(
      tableProdutos,
      where: 'orcamento_id = ?',
      whereArgs: [id],
    );

    orcamento = {...orcamento, 'produtos': produtos};

    return orcamento;
  }

  Future<void> deleteOrcamento(int id) async {
    final db = await database;
    await db.delete(tableOrcamentos, where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalOrcamentos() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(valor_total) as total FROM $tableOrcamentos',
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> insertAnotacao(Map<String, dynamic> anotacao) async {
    final db = await database;
    final String data = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    return await db.insert(tableAnotacoes, {
      'titulo': anotacao['titulo'].toString().trim(),
      'conteudo': anotacao['conteudo'].toString().trim(),
      'data': data,
    });
  }

  Future<List<Map<String, dynamic>>> getAnotacoes() async {
    final db = await database;
    return await db.query(tableAnotacoes, orderBy: 'data DESC');
  }

  Future<void> deleteAnotacao(int id) async {
    final db = await database;
    await db.delete(tableAnotacoes, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateAnotacao(Map<String, dynamic> anotacao) async {
    final db = await database;
    return await db.update(
      tableAnotacoes,
      {
        'titulo': anotacao['titulo'].toString().trim(),
        'conteudo': anotacao['conteudo'].toString().trim(),
      },
      where: 'id = ?',
      whereArgs: [anotacao['id']],
    );
  }

  Future<int> updateOrcamento(Map<String, dynamic> orcamento) async {
    final db = await database;

    return await db.transaction<int>((txn) async {
      final id = orcamento['id'];

      final result = await txn.update(
        tableOrcamentos,
        {
          'cliente': orcamento['cliente'].toString().trim(),
          'valor_total': orcamento['valor_total'],
          'desconto': orcamento['desconto'] ?? 0.0,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      await txn.delete(
        tableProdutos,
        where: 'orcamento_id = ?',
        whereArgs: [id],
      );

      final batch = txn.batch();
      for (final produto in orcamento['produtos']) {
        batch.insert(tableProdutos, {
          'orcamento_id': id,
          'nome': produto['nome'].toString().trim(),
          'preco': double.tryParse(produto['preco'].toString()) ?? 0.0,
          'quantidade': produto['quantidade'] ?? 1,
        });
      }
      await batch.commit();

      return result;
    });
  }
}
