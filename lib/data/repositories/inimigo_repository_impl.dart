import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';
import 'package:trabalho_rpg/data/models/arma_model.dart';
import 'package:trabalho_rpg/data/models/armadura_model.dart'; // NEW IMPORT: Assuming you have an ArmaduraModel
import 'package:trabalho_rpg/data/models/inimigo_model.dart';
import 'package:trabalho_rpg/data/repositories/arma_repository_impl.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart'; // NEW IMPORT: For the Armadura entity type
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_inimigo_repository.dart';
import 'package:trabalho_rpg/domain/entities/enums/proficiencias.dart'; // NEW IMPORT: Needed for ArmaduraModel.fromMap

class InimigoRepositoryImpl implements IInimigoRepository {
  final DatabaseHelper _dbHelper;
  final IHabilidadeRepository _habilidadeRepository;

  InimigoRepositoryImpl({
    required DatabaseHelper dbHelper,
    required IHabilidadeRepository habilidadeRepository, required ArmaRepositoryImpl armaRepository,
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
          habilidadesPreparadas: [], // Not saved directly in inimigo table
          tipo: inimigo.tipo,
          arma: inimigo.arma,
          armadura: inimigo.armadura,
        );
        await txn.insert('inimigos', inimigoModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        // Save abilities
        await txn.delete('combatente_habilidades',
            where: 'combatenteId = ?', whereArgs: [inimigo.id]);
        for (var habilidade in inimigo.habilidadesPreparadas) {
          await txn.insert('combatente_habilidades', {
            'combatenteId': inimigo.id,
            'habilidadeId': habilidade.id,
            'tipo': 'prepared' // Use 'prepared' as a string literal
          });
        }

        // Save equipment (arma and armadura) links
        await txn.delete('combatente_equipamentos',
            where: 'combatenteId = ?', whereArgs: [inimigo.id]);

        if (inimigo.arma != null) {
          await txn.insert('combatente_equipamentos', {
            'combatenteId': inimigo.id,
            'itemId': inimigo.arma!.id,
            'slot': 'arma'
          });
        }
        if (inimigo.armadura != null) {
          await txn.insert('combatente_equipamentos', {
            'combatenteId': inimigo.id,
            'itemId': inimigo.armadura!.id,
            'slot': 'armadura'
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

      // CORRECTED SQL: LEFT JOIN armaduras table for armadura data
      const String sql = '''
        SELECT i.*,
          arma.id as armaId, arma.nome as armaNome, arma.danoBase as armaDanoBase,
          armadura.id as armaduraId, armadura.nome as armaduraNome, 
          armadura.danoReduzido as armaduraDanoReduzido, 
          armadura.proficienciaRequerida as armaduraProficienciaRequerida
        FROM inimigos i
        LEFT JOIN armas arma ON i.armaId = arma.id
        LEFT JOIN armaduras armadura ON i.armaduraId = armadura.id -- CORRECTED JOIN TABLE
        WHERE i.id = ?
      ''';
      final List<Map<String, dynamic>> maps = await db.rawQuery(sql, [id]);

      if (maps.isEmpty) return null;

      final inimigoMap = maps.first;
      final habilidadesMap = await _habilidadeRepository.getAllForCombatente(id);
      final habilidades = habilidadesMap['prepared'] ?? []; // Inimigos only have prepared abilities

      final arma = inimigoMap['armaId'] != null
          ? ArmaModel(
              id: inimigoMap['armaId'] as String,
              nome: inimigoMap['armaNome'] as String,
              danoBase: inimigoMap['armaDanoBase'] as int,
            )
          : null;

      Armadura? armadura; // Declare as Armadura?
      if (inimigoMap['armaduraId'] != null) {
        armadura = ArmaduraModel( // Use ArmaduraModel if available, else Armadura
          id: inimigoMap['armaduraId'] as String,
          nome: inimigoMap['armaduraNome'] as String,
          danoReduzido: inimigoMap['armaduraDanoReduzido'] as int,
          proficienciaRequerida: ProficienciaArmadura.values[inimigoMap['armaduraProficienciaRequerida'] as int], // Convert int to enum
        );
      }


      return InimigoModel.fromMap(
        inimigoMap,
        arma: arma,
        armadura: armadura, // Now of type Armadura?
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
        final inimigo = await getById(map['id'] as String); // Ensure ID is String
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
      // Also delete related combatente_habilidades and combatente_equipamentos
      await db.delete('combatente_habilidades', where: 'combatenteId = ?', whereArgs: [id]);
      await db.delete('combatente_equipamentos', where: 'combatenteId = ?', whereArgs: [id]);
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao deletar o inimigo.', originalException: e);
    }
  }
}