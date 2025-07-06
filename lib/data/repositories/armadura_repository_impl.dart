import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';
import 'package:trabalho_rpg/domain/repositories/i_armadura_repository.dart';

class ArmaduraRepositoryImpl implements IArmaduraRepository {
  final DatabaseHelper dbHelper;

  ArmaduraRepositoryImpl({required this.dbHelper});

  @override
  Future<List<Armadura>> getAllArmaduras() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('armaduras');
    return List.generate(maps.length, (i) {
      return Armadura(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        danoReduzido: maps[i]['danoReduzido'],
        proficienciaRequerida: ProficienciaArmadura.values[maps[i]['proficienciaRequerida']],
      );
    });
  }

  @override
  Future<Armadura?> getArmaduraById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'armaduras',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Armadura(
        id: maps[0]['id'],
        nome: maps[0]['nome'],
        danoReduzido: maps[0]['danoReduzido'],
        proficienciaRequerida: ProficienciaArmadura.values[maps[0]['proficienciaRequerida']],
      );
    }
    return null;
  }

  @override
  Future<void> saveArmadura(Armadura armadura) async {
    final db = await dbHelper.database;
    await db.insert(
      'armaduras',
      {
        'id': armadura.id,
        'nome': armadura.nome,
        'danoReduzido': armadura.danoReduzido,
        'proficienciaRequerida': armadura.proficienciaRequerida.index, // Store enum index
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteArmadura(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'armaduras',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}