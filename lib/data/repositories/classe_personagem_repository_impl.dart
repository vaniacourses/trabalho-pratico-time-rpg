import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/models/classe_personagem_model.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';

class ClassePersonagemRepositoryImpl implements IClassePersonagemRepository {
  final DatabaseHelper _dbHelper;

  ClassePersonagemRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<void> save(ClassePersonagem classe) async {
    final db = await _dbHelper.database;
    // Como o model e a entidade têm os mesmos campos para persistência,
    // podemos criar o model diretamente.
    final classeModel = ClassePersonagemModel(
      id: classe.id,
      nome: classe.nome,
      proficienciaArmadura: classe.proficienciaArmadura,
      proficienciaArma: classe.proficienciaArma,
    );

    await db.insert(
      'classes_personagem',
      classeModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'classes_personagem',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<ClassePersonagem?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes_personagem',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ClassePersonagemModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<ClassePersonagem>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('classes_personagem');

    return List.generate(maps.length, (i) {
      return ClassePersonagemModel.fromMap(maps[i]);
    });
  }
}