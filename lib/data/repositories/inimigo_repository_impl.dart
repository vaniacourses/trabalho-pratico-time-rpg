import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';
import 'package:trabalho_rpg/data/models/arma_model.dart';
import 'package:trabalho_rpg/data/models/inimigo_model.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_inimigo_repository.dart';

class InimigoRepositoryImpl implements IInimigoRepository {
  final DatabaseHelper _dbHelper;
  // CORREÇÃO: Adicionada a dependência do repositório de habilidades.
  final IHabilidadeRepository _habilidadeRepository;

  InimigoRepositoryImpl({
    required DatabaseHelper dbHelper,
    required IHabilidadeRepository habilidadeRepository,
  })  : _dbHelper = dbHelper,
        _habilidadeRepository = habilidadeRepository;

  @override
  Future<void> save(Inimigo inimigo) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      try {
        final inimigoModel = InimigoModel(
          id: inimigo.id,
          nome: inimigo.nome,
          nivel: inimigo.nivel,
          vidaMax: inimigo.vidaMax,
          classeArmadura: inimigo.classeArmadura,
          atributosBase: inimigo.atributosBase,
          habilidadesPreparadas: [],
          tipo: inimigo.tipo,
          arma: inimigo.arma,
          armadura: inimigo.armadura,
        );
        await txn.insert('inimigos', inimigoModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        await txn.delete('combatente_habilidades',
            where: 'combatenteId = ?', whereArgs: [inimigo.id]);

        for (var habilidade in inimigo.habilidadesPreparadas) {
          await txn.insert('combatente_habilidades', {
            'combatenteId': inimigo.id,
            'habilidadeId': habilidade.id,
            'tipo': 'preparada'
          });
        }
      } catch (e) {
        throw DatasourceException(
            message: 'Falha ao salvar o inimigo.', originalException: e);
      }
    });
  }

  @override
  Future<Inimigo?> getById(String id) async {
    try {
      final db = await _dbHelper.database;

      const String sql = '''
        SELECT i.*,
          arma.id as armaId, arma.nome as armaNome, arma.danoBase as armaDanoBase,
          armadura.id as armaduraId, armadura.nome as armaduraNome, armadura.danoBase as armaduraDanoBase
        FROM inimigos i
        LEFT JOIN armas arma ON i.armaId = arma.id
        LEFT JOIN armas armadura ON i.armaduraId = armadura.id
        WHERE i.id = ?
      ''';
      final List<Map<String, dynamic>> maps = await db.rawQuery(sql, [id]);

      if (maps.isEmpty) return null;

      final inimigoMap = maps.first;
      // CORREÇÃO: Chama o repositório de habilidade.
      final habilidadesMap = await _habilidadeRepository.getAllForCombatente(id);
      // Inimigos só têm habilidades preparadas.
      final habilidades = habilidadesMap['preparadas'] ?? [];

      final arma = inimigoMap['armaId'] != null
          ? ArmaModel(id: inimigoMap['armaId'], nome: inimigoMap['armaNome'], danoBase: inimigoMap['armaDanoBase'])
          : null;

      final armadura = inimigoMap['armaduraId'] != null
          ? ArmaModel(id: inimigoMap['armaduraId'], nome: inimigoMap['armaduraNome'], danoBase: inimigoMap['armaduraDanoBase'])
          : null;

      return InimigoModel.fromMap(
        inimigoMap,
        arma: arma,
        armadura: armadura,
        habilidades: habilidades,
      );
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao buscar inimigo por ID.', originalException: e);
    }
  }

  @override
  Future<List<Inimigo>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('inimigos');
      
      final List<Inimigo> inimigos = [];
      for (final map in maps) {
        final inimigo = await getById(map['id']);
        if (inimigo != null) {
          inimigos.add(inimigo);
        }
      }
      return inimigos;
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao buscar todos os inimigos.', originalException: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('inimigos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao deletar o inimigo.', originalException: e);
    }
  }

  // CORREÇÃO: O método _getHabilidadesForCombatente foi REMOVIDO deste arquivo.
}