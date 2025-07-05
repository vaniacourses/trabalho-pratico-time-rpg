import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';
import 'package:trabalho_rpg/data/models/arma_model.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';

class ArmaRepositoryImpl implements IArmaRepository {
  final DatabaseHelper _dbHelper;

  ArmaRepositoryImpl({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  @override
  Future<void> save(Arma arma) async {
    try {
      final db = await _dbHelper.database;
      final armaModel = ArmaModel(
        id: arma.id,
        nome: arma.nome,
        danoBase: arma.danoBase,
      );

      await db.insert(
        'armas',
        armaModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatasourceException(
        message: 'Falha ao salvar a arma.',
        originalException: e,
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('armas', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatasourceException(
        message: 'Falha ao deletar a arma.',
        originalException: e,
      );
    }
  }

  @override
  Future<Arma?> getById(String id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'armas',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return ArmaModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw DatasourceException(
        message: 'Falha ao buscar arma por ID.',
        originalException: e,
      );
    }
  }

  @override
  Future<List<Arma>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('armas');

      return List.generate(maps.length, (i) {
        return ArmaModel.fromMap(maps[i]);
      });
    } catch (e) {
      throw DatasourceException(
        message: 'Falha ao buscar todas as armas.',
        originalException: e,
      );
    }
  }
}