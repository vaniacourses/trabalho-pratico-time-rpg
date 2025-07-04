import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/models/classe_personagem_model.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';

class ClassePersonagemRepositoryImpl implements IClassePersonagemRepository {
  final DatabaseHelper _dbHelper;

  ClassePersonagemRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<void> save(ClassePersonagem classe) async {
    // ADICIONADO: Bloco try-catch para tratar possíveis erros do BD.
    try {
      final db = await _dbHelper.database;
      
      // Converte a entidade de domínio para o modelo de dados.
      final classeModel = ClassePersonagemModel(
        id: classe.id,
        nome: classe.nome,
        proficienciaArmadura: classe.proficienciaArmadura,
        proficienciaArma: classe.proficienciaArma,
      );

      // Insere o modelo no banco de dados.
      await db.insert(
        'classes_personagem',
        classeModel.toMap(),
        // NOVO COMENTÁRIO: Se uma classe com o mesmo ID já existir, ela será substituída.
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // ADICIONADO: Relança o erro como uma exceção da camada de dados.
      throw DatasourceException(
          message: 'Falha ao salvar a classe de personagem.',
          originalException: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    // ADICIONADO: Bloco try-catch para tratar possíveis erros do BD.
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'classes_personagem',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // ADICIONADO: Relança o erro como uma exceção da camada de dados.
      throw DatasourceException(
          message: 'Falha ao deletar a classe de personagem.',
          originalException: e);
    }
  }

  @override
  Future<ClassePersonagem?> getById(String id) async {
    // ADICIONADO: Bloco try-catch para tratar possíveis erros do BD.
    try {
      final db = await _dbHelper.database;

      // Executa uma query para buscar uma classe pelo seu ID.
      final List<Map<String, dynamic>> maps = await db.query(
        'classes_personagem',
        where: 'id = ?',
        whereArgs: [id],
      );

      // Se encontrou um resultado, converte o Map para um modelo.
      if (maps.isNotEmpty) {
        return ClassePersonagemModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      // ADICIONADO: Relança o erro como uma exceção da camada de dados.
      throw DatasourceException(
          message: 'Falha ao buscar classe de personagem por ID.',
          originalException: e);
    }
  }

  @override
  Future<List<ClassePersonagem>> getAll() async {
    // ADICIONADO: Bloco try-catch para tratar possíveis erros do BD.
    try {
      final db = await _dbHelper.database;

      // Executa uma query para buscar todas as classes.
      final List<Map<String, dynamic>> maps =
          await db.query('classes_personagem');

      // Mapeia a lista de Maps para uma lista de entidades.
      return List.generate(maps.length, (i) {
        return ClassePersonagemModel.fromMap(maps[i]);
      });
    } catch (e) {
      // ADICIONADO: Relança o erro como uma exceção da camada de dados.
      throw DatasourceException(
          message: 'Falha ao buscar todas as classes de personagem.',
          originalException: e);
    }
  }
}