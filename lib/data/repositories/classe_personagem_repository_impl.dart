import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart'; // Import if needed for abilities

class ClassePersonagemRepositoryImpl implements IClassePersonagemRepository {
  final DatabaseHelper dbHelper;

  ClassePersonagemRepositoryImpl({required this.dbHelper});

  @override
  Future<List<ClassePersonagem>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('classes_personagem');
    return List.generate(maps.length, (i) {
      return ClassePersonagem(
        id: maps[i]['id'] as String,
        nome: maps[i]['nome'] as String,
        // CORRECTED: Cast to int to get enum value from index
        proficienciaArmadura: ProficienciaArmadura.values[maps[i]['proficienciaArmadura'] as int],
        proficienciaArma: ProficienciaArma.values[maps[i]['proficienciaArma'] as int],
        habilidadesDisponiveis: [], // Assuming abilities are not directly loaded with class
      );
    });
  }

  @override
  Future<ClassePersonagem?> getById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes_personagem',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ClassePersonagem(
        id: maps[0]['id'] as String,
        nome: maps[0]['nome'] as String,
        // CORRECTED: Cast to int to get enum value from index
        proficienciaArmadura: ProficienciaArmadura.values[maps[0]['proficienciaArmadura'] as int],
        proficienciaArma: ProficienciaArma.values[maps[0]['proficienciaArma'] as int],
        habilidadesDisponiveis: [], // Assuming abilities are not directly loaded with class
      );
    }
    return null;
  }

  @override
  Future<void> save(ClassePersonagem classe) async {
    final db = await dbHelper.database;
    await db.insert(
      'classes_personagem',
      {
        'id': classe.id,
        'nome': classe.nome,
        'proficienciaArmadura': classe.proficienciaArmadura.index, // CORRECTED: Store enum index
        'proficienciaArma': classe.proficienciaArma.index, // CORRECTED: Store enum index
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'classes_personagem',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}