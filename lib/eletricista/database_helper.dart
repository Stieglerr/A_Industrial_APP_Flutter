import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  // Table names
  static const String tableOrcamentos = 'orcamentos';
  static const String tableProdutos = 'produtos';
  static const String tableAnotacoes = 'anotacoes';

  // Current database version
  static const int dbVersion = 7;

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
    return await openDatabase(
      join(path, 'app_database.db'),
      version: dbVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
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
      )
    ''');

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
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAnotacoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        conteudo TEXT NOT NULL,
        data TEXT NOT NULL
      )
    ''');
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
          quantidade INTEGER DEFAULT 1,
          FOREIGN KEY(orcamento_id) 
            REFERENCES $tableOrcamentos(id) 
            ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE $tableOrcamentos 
        ADD COLUMN valor_total REAL DEFAULT 0.0
      ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE $tableAnotacoes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          conteudo TEXT NOT NULL,
          data TEXT NOT NULL
        )
      ''');

      await db.execute('''
        ALTER TABLE $tableOrcamentos 
        ADD COLUMN desconto REAL DEFAULT 0.0
      ''');
    }

    if (oldVersion < 5) {
      try {
        await db.execute(
          'ALTER TABLE $tableProdutos ADD COLUMN quantidade INTEGER DEFAULT 1',
        );
      } catch (e) {
        debugPrint('Error adding quantidade column: $e');
      }
    }

    if (oldVersion < 6) {
      try {
        await db.execute('''
          CREATE TABLE ${tableOrcamentos}_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente TEXT NOT NULL,
            data TEXT NOT NULL,
            valor_total REAL DEFAULT 0.0,
            desconto REAL DEFAULT 0.0
          )
        ''');

        await db.execute('''
          INSERT INTO ${tableOrcamentos}_new 
          SELECT id, cliente, data, valor_total, desconto 
          FROM $tableOrcamentos
        ''');

        await db.execute('DROP TABLE $tableOrcamentos');
        await db.execute(
          'ALTER TABLE ${tableOrcamentos}_new RENAME TO $tableOrcamentos',
        );
      } catch (e) {
        debugPrint('Error during orcamentos migration: $e');
      }
    }

    if (oldVersion < 7) {
      try {
        await db.execute('''
          CREATE TABLE ${tableProdutos}_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orcamento_id INTEGER NOT NULL,
            nome TEXT NOT NULL,
            preco REAL NOT NULL,
            quantidade INTEGER DEFAULT 1,
            FOREIGN KEY(orcamento_id) 
              REFERENCES $tableOrcamentos(id) 
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          INSERT INTO ${tableProdutos}_new 
          SELECT id, orcamento_id, nome, preco, quantidade 
          FROM $tableProdutos
        ''');

        await db.execute('DROP TABLE $tableProdutos');
        await db.execute(
          'ALTER TABLE ${tableProdutos}_new RENAME TO $tableProdutos',
        );

        debugPrint(
          'Successfully migrated produtos table with proper foreign key',
        );
      } catch (e) {
        debugPrint('Error during produtos table migration: $e');
        rethrow;
      }
    }
  }

  Future<int> insertOrcamento(Map<String, dynamic> orcamento) async {
    final db = await database;
    final String data = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    try {
      return await db.transaction<int>((txn) async {
        final orcamentoId = await txn.insert(tableOrcamentos, {
          'cliente':
              orcamento['cliente']?.toString().trim() ??
              'Cliente não informado',
          'data': data,
          'valor_total': 0.0,
          'desconto': (orcamento['desconto'] as num?)?.toDouble() ?? 0.0,
        });

        if (orcamentoId == 0) {
          throw Exception('Failed to insert orcamento - no ID generated');
        }

        final insertedOrcamento = await txn.query(
          tableOrcamentos,
          where: 'id = ?',
          whereArgs: [orcamentoId],
          limit: 1,
        );

        if (insertedOrcamento.isEmpty) {
          throw Exception('Orcamento insertion failed verification');
        }

        final produtos =
            (orcamento['produtos'] as List?)?.map((p) {
              final produto = p as Map<String, dynamic>;

              if (produto['nome'] == null || produto['preco'] == null) {
                throw Exception('Product data is incomplete');
              }

              final preco = (produto['preco'] as num).toDouble();
              final quantidade = (produto['quantidade'] as num?)?.toInt() ?? 1;

              if (preco < 0 || quantidade <= 0) {
                throw Exception('Invalid product price or quantity');
              }

              return {
                'nome': produto['nome'].toString().trim(),
                'preco': preco,
                'quantidade': quantidade,
              };
            }).toList() ??
            [];

        double total = 0.0;
        final batch = txn.batch();

        for (final produto in produtos) {
          final preco = produto['preco'] as double;
          final quantidade = produto['quantidade'] as int;
          total += preco * quantidade;

          batch.insert(tableProdutos, {
            'orcamento_id': orcamentoId,
            'nome': produto['nome'] as String,
            'preco': preco,
            'quantidade': quantidade,
          });
        }

        await batch.commit();

        await txn.update(
          tableOrcamentos,
          {'valor_total': total},
          where: 'id = ?',
          whereArgs: [orcamentoId],
        );

        return orcamentoId;
      });
    } catch (e) {
      debugPrint('Error in insertOrcamento: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOrcamentos() async {
    final db = await database;
    final orcamentos = await db.query(tableOrcamentos, orderBy: 'data DESC');

    final List<Map<String, dynamic>> result = [];

    for (final orcamento in orcamentos) {
      final produtos = await db.query(
        tableProdutos,
        where: 'orcamento_id = ?',
        whereArgs: [orcamento['id']],
      );

      result.add({...orcamento, 'produtos': produtos});
    }

    return result;
  }

  Future<Map<String, dynamic>?> getOrcamentoById(int id) async {
    final db = await database;
    final orcamento = await db
        .query(tableOrcamentos, where: 'id = ?', whereArgs: [id])
        .then((value) => value.isNotEmpty ? value.first : null);

    if (orcamento == null) return null;

    final produtos = await db.query(
      tableProdutos,
      where: 'orcamento_id = ?',
      whereArgs: [id],
    );

    return {...orcamento, 'produtos': produtos};
  }

  Future<int> updateOrcamento(Map<String, dynamic> orcamento) async {
    final db = await database;
    final id = orcamento['id'] as int;

    return await db.transaction<int>((txn) async {
      double total = 0.0;
      final produtos =
          (orcamento['produtos'] as List?)?.map((p) {
            final produto = p as Map<String, dynamic>;

            if (produto['nome'] == null || produto['preco'] == null) {
              throw Exception('Product data is incomplete');
            }

            final preco = (produto['preco'] as num).toDouble();
            final quantidade = (produto['quantidade'] as num?)?.toInt() ?? 1;
            total += preco * quantidade;

            return {
              'nome': produto['nome'].toString().trim(),
              'preco': preco,
              'quantidade': quantidade,
            };
          }).toList() ??
          [];

      final result = await txn.update(
        tableOrcamentos,
        {
          'cliente':
              orcamento['cliente']?.toString().trim() ??
              'Cliente não informado',
          'valor_total': total,
          'desconto': (orcamento['desconto'] as num?)?.toDouble() ?? 0.0,
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
      for (final produto in produtos) {
        batch.insert(tableProdutos, {
          'orcamento_id': id,
          'nome': produto['nome'] as String,
          'preco': produto['preco'] as double,
          'quantidade': produto['quantidade'] as int,
        });
      }
      await batch.commit();

      return result;
    });
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
      'titulo': anotacao['titulo']?.toString().trim() ?? 'Sem título',
      'conteudo': anotacao['conteudo']?.toString().trim() ?? '',
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
        'titulo': anotacao['titulo']?.toString().trim() ?? 'Sem título',
        'conteudo': anotacao['conteudo']?.toString().trim() ?? '',
      },
      where: 'id = ?',
      whereArgs: [anotacao['id']],
    );
  }

  Future<void> verifyDatabaseIntegrity() async {
    final db = await database;
    try {
      final fkCheck = await db.rawQuery('PRAGMA foreign_key_check');
      if (fkCheck.isNotEmpty) {
        debugPrint('Foreign key violations found: $fkCheck');
        throw Exception('Database has foreign key violations');
      }

      final fkList = await db.rawQuery(
        'PRAGMA foreign_key_list($tableProdutos)',
      );
      debugPrint('Foreign key constraints for produtos: $fkList');

      if (fkList.isEmpty) {
        throw Exception('No foreign key constraint found for produtos table');
      }

      final orcamentosInfo = await db.rawQuery(
        'PRAGMA table_info($tableOrcamentos)',
      );
      final produtosInfo = await db.rawQuery(
        'PRAGMA table_info($tableProdutos)',
      );

      debugPrint('Orcamentos table structure: $orcamentosInfo');
      debugPrint('Produtos table structure: $produtosInfo');
    } catch (e) {
      debugPrint('Error verifying database integrity: $e');
      rethrow;
    }
  }

  Future<void> resetDatabase() async {
    final path = await getDatabasesPath();
    final file = File('$path/app_database.db');
    if (await file.exists()) {
      await file.delete();
    }
    _database = null;
  }
}
