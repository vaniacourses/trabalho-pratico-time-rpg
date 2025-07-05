import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';
import 'package:trabalho_rpg/data/models/arma_model.dart';
import 'package:trabalho_rpg/data/models/classe_personagem_model.dart';
import 'package:trabalho_rpg/data/models/personagem_model.dart';
import 'package:trabalho_rpg/data/models/raca_model.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';

class PersonagemRepositoryImpl implements IPersonagemRepository {
  final DatabaseHelper _dbHelper;
  // CORREÇÃO: Adicionada a dependência do repositório de habilidades.
  final IHabilidadeRepository _habilidadeRepository;

  PersonagemRepositoryImpl({
    required DatabaseHelper dbHelper,
    required IHabilidadeRepository habilidadeRepository,
  }) : _dbHelper = dbHelper,
       _habilidadeRepository = habilidadeRepository;

  @override
  Future<void> save(Personagem personagem) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      try {
        final personagemModel = PersonagemModel(
          id: personagem.id,
          nome: personagem.nome,
          nivel: personagem.nivel,
          vidaMax: personagem.vidaMax,
          classeArmadura: personagem.classeArmadura,
          atributosBase: personagem.atributosBase,
          raca: personagem.raca,
          classe: personagem.classe,
          arma: personagem.arma,
          armadura: personagem.armadura,
          habilidadesConhecidas: [],
          habilidadesPreparadas: [],
          equipamentos: {},
        );
        await txn.insert(
          'personagens',
          personagemModel.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        
        final Map<String, String> habilidadesParaSalvar = {};
        for (var habilidade in personagem.habilidadesConhecidas) {
          habilidadesParaSalvar[habilidade.id] = 'conhecida';
        }
        for (var habilidade in personagem.habilidadesPreparadas) {
          habilidadesParaSalvar[habilidade.id] = 'preparada';
        }

        await txn.delete(
          'combatente_habilidades',
          where: 'combatenteId = ?',
          whereArgs: [personagem.id],
        );

        for (var entry in habilidadesParaSalvar.entries) {
          await txn.insert('combatente_habilidades', {
            'combatenteId': personagem.id,
            'habilidadeId': entry.key,
            'tipo': entry.value,
          });
        }

        await txn.delete(
          'combatente_equipamentos',
          where: 'combatenteId = ?',
          whereArgs: [personagem.id],
        );

        for (var entry in personagem.equipamentos.entries) {
          await txn.insert('combatente_equipamentos', {
            'combatenteId': personagem.id,
            'armaId': entry.value.id,
            'slot': entry.key,
          });
        }
      } catch (e) {
        throw DatasourceException(
          message: 'Falha ao salvar o personagem e suas relações.',
          originalException: e,
        );
      }
    });
  }

  @override
  Future<Personagem?> getById(String id) async {
    try {
      final db = await _dbHelper.database;
      
      const String sql = '''
        SELECT p.*,
          r.nome as racaNome, r.modificadoresDeAtributo,
          c.nome as classeNome, c.proficienciaArmadura as classeProficienciaArmadura, c.proficienciaArma as classeProficienciaArma,
          arma.id as armaId, arma.nome as armaNome, arma.danoBase as armaDanoBase,
          armadura.id as armaduraId, armadura.nome as armaduraNome, armadura.danoBase as armaduraDanoBase
        FROM personagens p
        JOIN racas r ON p.racaId = r.id
        JOIN classes_personagem c ON p.classeId = c.id
        LEFT JOIN armas arma ON p.armaId = arma.id
        LEFT JOIN armas armadura ON p.armaduraId = armadura.id
        WHERE p.id = ?
      ''';
      final List<Map<String, dynamic>> maps = await db.rawQuery(sql, [id]);

      if (maps.isEmpty) return null;

      final personagemMap = maps.first;

      // CORREÇÃO: A lógica de busca de habilidades e equipamentos foi centralizada.
      final habilidades = await _habilidadeRepository.getAllForCombatente(id);
      final equipamentos = await _getEquipamentosForCombatente(db, id);

      return _mapToPersonagem(
        personagemMap,
        habilidades: habilidades,
        equipamentos: equipamentos,
      );
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao buscar personagem por ID.',
          originalException: e);
    }
  }

  @override
  Future<List<Personagem>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('personagens');

      final List<Personagem> personagens = [];
      for (final map in maps) {
        final personagem = await getById(map['id']);
        if (personagem != null) {
          personagens.add(personagem);
        }
      }
      return personagens;
    } catch (e) {
      throw DatasourceException(
        message: 'Falha ao buscar todos os personagens.',
        originalException: e,
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('personagens', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatasourceException(
        message: 'Falha ao deletar o personagem.',
        originalException: e,
      );
    }
  }

  // CORREÇÃO: O método _getHabilidadesForCombatente foi REMOVIDO deste arquivo.
  // A responsabilidade agora é do HabilidadeRepository.

  Future<Map<String, Arma>> _getEquipamentosForCombatente(
    DatabaseExecutor db,
    String combatenteId,
  ) async {
    const String sql = '''
      SELECT a.*, ce.slot FROM armas a
      JOIN combatente_equipamentos ce ON a.id = ce.armaId
      WHERE ce.combatenteId = ?
    ''';
    final maps = await db.rawQuery(sql, [combatenteId]);

    final Map<String, Arma> equipamentos = {};
    for (final map in maps) {
      equipamentos[map['slot'] as String] = ArmaModel.fromMap(map);
    }
    return equipamentos;
  }

  Personagem _mapToPersonagem(
    Map<String, dynamic> map, {
    required Map<String, List<Habilidade>> habilidades,
    required Map<String, Arma> equipamentos,
  }) {
    final raca = RacaModel.fromMap({
      'id': map['racaId'],
      'nome': map['racaNome'],
      'modificadoresDeAtributo': map['modificadoresDeAtributo'],
    });

    final classe = ClassePersonagemModel.fromMap({
      'id': map['classeId'],
      'nome': map['classeNome'],
      'proficienciaArmadura': map['classeProficienciaArmadura'],
      'proficienciaArma': map['classeProficienciaArma'],
    });

    final arma = map['armaId'] != null
        ? ArmaModel(
            id: map['armaId'],
            nome: map['armaNome'],
            danoBase: map['armaDanoBase'],
          )
        : null;
    final armadura = map['armaduraId'] != null
        ? ArmaModel(
            id: map['armaduraId'],
            nome: map['armaduraNome'],
            danoBase: map['armaduraDanoBase'],
          )
        : null;

    return PersonagemModel.fromMap(
      map,
      raca: raca,
      classe: classe,
      arma: arma,
      armadura: armadura,
      habilidadesConhecidas: habilidades['conhecidas'] ?? [],
      habilidadesPreparadas: habilidades['preparadas'] ?? [],
      equipamentos: equipamentos,
    );
  }
}