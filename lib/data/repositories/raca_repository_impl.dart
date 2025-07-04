import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/models/raca_model.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';

class RacaRepositoryImpl implements IRacaRepository {
  final DatabaseHelper _dbHelper;

  RacaRepositoryImpl({required DatabaseHelper dbHelper}) : _dbHelper = dbHelper;

  @override
  Future<void> save(Raca raca) async {
    // ADICIONADO: Bloco try-catch para garantir a robustez da operação.
    try {
      final db = await _dbHelper.database;
      // Converte a entidade de domínio para o modelo de dados.
      final racaModel = RacaModel(
        id: raca.id,
        nome: raca.nome,
        modificadoresDeAtributo: raca.modificadoresDeAtributo,
      );

      // Insere o modelo no banco, substituindo se já existir um com o mesmo ID.
      await db.insert(
        'racas',
        racaModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // ADICIONADO: Relança um erro específico da camada de dados.
      throw DatasourceException(
          message: 'Falha ao salvar a raça.',
          originalException: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    // ADICIONADO: Bloco try-catch para garantir a robustez da operação.
    try {
      final db = await _dbHelper.database;
      await db.delete('racas', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      // ADICIONADO: Relança um erro específico da camada de dados.
      throw DatasourceException(
          message: 'Falha ao deletar a raça.',
          originalException: e);
    }
  }

  @override
  Future<Raca?> getById(String id) async {
    // ADICIONADO: Bloco try-catch para garantir a robustez da operação.
    try {
      final db = await _dbHelper.database;

      // Executa uma query para buscar uma raça pelo seu ID.
      final List<Map<String, dynamic>> maps = await db.query(
        'racas',
        where: 'id = ?',
        whereArgs: [id],
      );

      // Se um resultado for encontrado, o converte para um modelo.
      if (maps.isNotEmpty) {
        return RacaModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      // ADICIONADO: Relança um erro específico da camada de dados.
      throw DatasourceException(
          message: 'Falha ao buscar raça por ID.',
          originalException: e);
    }
  }

  @override
  Future<List<Raca>> getAll() async {
    // ADICIONADO: Bloco try-catch para garantir a robustez da operação.
    try {
      final db = await _dbHelper.database;
      
      // Executa uma query para buscar todas as raças da tabela.
      final List<Map<String, dynamic>> maps = await db.query('racas');

      // Mapeia a lista de Maps do banco para uma lista de entidades Raca.
      return List.generate(maps.length, (i) {
        return RacaModel.fromMap(maps[i]);
      });
    } catch (e) {
      // ADICIONADO: Relança um erro específico da camada de dados.
      throw DatasourceException(
          message: 'Falha ao buscar todas as raças.',
          originalException: e);
    }
  }
}