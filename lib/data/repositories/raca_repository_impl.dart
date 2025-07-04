import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/models/raca_model.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';

class RacaRepositoryImpl implements IRacaRepository {
  final DatabaseHelper _dbHelper;

  RacaRepositoryImpl({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  @override
  Future<void> save(Raca raca) async {
    final db = await _dbHelper.database;
    final racaModel = RacaModel(
      id: raca.id,
      nome: raca.nome,
      modificadoresDeAtributo: raca.modificadoresDeAtributo,
    );

    await db.insert(
      'racas',
      racaModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('racas', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Raca?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'racas',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RacaModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<Raca>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('racas');

    return List.generate(maps.length, (i) {
      return RacaModel.fromMap(maps[i]);
    });
  }
}
