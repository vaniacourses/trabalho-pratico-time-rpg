import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/models/personagem_model.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/models/raca_model.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/data/models/classe_personagem_model.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';

class PersonagemRepositoryImpl implements IPersonagemRepository {
  // O repositório depende do DatabaseHelper para acessar o banco.
  final DatabaseHelper _dbHelper;

  PersonagemRepositoryImpl({required DatabaseHelper dbHelper})
    : _dbHelper = dbHelper;

  @override
  Future<void> save(Personagem personagem) async {
    // ADICIONADO: Bloco try-catch para tratar possíveis erros do BD.
    try {
      final db = await _dbHelper.database;

      // Converte a entidade de domínio 'Personagem' para 'PersonagemModel',
      // que por sua vez é convertido para um Map pronto para o BD.
      final personagemModel = PersonagemModel(
        id: personagem.id,
        nome: personagem.nome,
        nivel: personagem.nivel,
        vidaMax: personagem.vidaMax,
        classeArmadura: personagem.classeArmadura,
        atributosBase: personagem.atributosBase,
        raca: personagem.raca,
        classe: personagem.classe,
      );

      await db.insert(
        'personagens',
        personagemModel.toMap(),
        // 'replace' garante que, se um personagem com o mesmo ID for salvo,
        // ele será atualizado (UPDATE) em vez de gerar um erro.
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // ADICIONADO: Relança o erro como uma exceção da camada de dados.
      throw DatasourceException(
          message: 'Falha ao salvar o personagem.',
          originalException: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    // ADICIONADO: Bloco try-catch para tratar possíveis erros do BD.
    try {
      final db = await _dbHelper.database;
      await db.delete('personagens', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      // ADICIONADO: Relança o erro como uma exceção da camada de dados.
      throw DatasourceException(
          message: 'Falha ao deletar o personagem.',
          originalException: e);
    }
  }

  @override
  Future<Personagem?> getById(String id) async {
    // ADICIONADO: Bloco try-catch para tratar possíveis erros do BD.
    try {
      final db = await _dbHelper.database;

      // Consulta SQL com JOIN para buscar dados de múltiplas tabelas de uma vez.
      const String sql = '''
        SELECT
          p.*,
          r.nome as racaNome, r.modificadoresDeAtributo,
          c.nome as classeNome, c.proficienciaArmadura as classeProficienciaArmadura, c.proficienciaArma as classeProficienciaArma
        FROM personagens p
        JOIN racas r ON p.racaId = r.id
        JOIN classes_personagem c ON p.classeId = c.id
        WHERE p.id = ?
      ''';

      final List<Map<String, dynamic>> maps = await db.rawQuery(sql, [id]);

      if (maps.isNotEmpty) {
        return _mapToPersonagem(maps.first);
      }
      return null;
    } catch (e) {
      // ADICIONADO: Relança o erro como uma exceção da camada de dados.
      throw DatasourceException(
          message: 'Falha ao buscar personagem por ID.',
          originalException: e);
    }
  }

  @override
  Future<List<Personagem>> getAll() async {
    // ADICIONADO: Bloco try-catch para tratar possíveis erros do BD.
    try {
      final db = await _dbHelper.database;

      // Consulta SQL com JOIN para buscar todos os personagens e seus dados relacionados.
      const String sql = '''
        SELECT
          p.*,
          r.nome as racaNome, r.modificadoresDeAtributo,
          c.nome as classeNome, c.proficienciaArmadura as classeProficienciaArmadura, c.proficienciaArma as classeProficienciaArma
        FROM personagens p
        JOIN racas r ON p.racaId = r.id
        JOIN classes_personagem c ON p.classeId = c.id
      ''';

      final List<Map<String, dynamic>> maps = await db.rawQuery(sql);

      // Mapeia a lista de Maps para uma lista de entidades Personagem.
      return maps.map((map) => _mapToPersonagem(map)).toList();
    } catch (e) {
      // ADICIONADO: Relança o erro como uma exceção da camada de dados.
      throw DatasourceException(
          message: 'Falha ao buscar todos os personagens.',
          originalException: e);
    }
  }

  /// Método auxiliar privado para evitar repetição de código.
  /// Converte um único Map (resultado da query com JOIN) em uma entidade Personagem.
  Personagem _mapToPersonagem(Map<String, dynamic> map) {
    // Reconstrói a Raca a partir dos dados do JOIN.
    final raca = RacaModel.fromMap({
      'id': map['racaId'],
      'nome': map['racaNome'],
      'modificadoresDeAtributo': map['modificadoresDeAtributo'],
    });

    // Reconstrói a Classe a partir dos dados do JOIN.
    final classe = ClassePersonagemModel.fromMap({
      'id': map['classeId'],
      'nome': map['classeNome'],
      'proficienciaArmadura': map['classeProficienciaArmadura'],
      'proficienciaArma': map['classeProficienciaArma'],
    });

    // Usa o construtor de fábrica do PersonagemModel para criar a entidade final.
    return PersonagemModel.fromMap(map, raca: raca, classe: classe);
  }
}