import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';
import 'package:trabalho_rpg/data/models/grupo_model.dart';
import 'package:trabalho_rpg/domain/entities/combatente.dart';
import 'package:trabalho_rpg/domain/entities/grupo.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/repositories/i_grupo_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_inimigo_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';

class GrupoRepositoryImpl<T extends Combatente> implements IGrupoRepository<T> {
  final DatabaseHelper _dbHelper;
  // O repositório de grupo depende dos outros repositórios para buscar os membros.
  final IPersonagemRepository _personagemRepository;
  final IInimigoRepository _inimigoRepository;
  final String _tipo;

  GrupoRepositoryImpl({
    required DatabaseHelper dbHelper,
    required IPersonagemRepository personagemRepository,
    required IInimigoRepository inimigoRepository,
  })  : _dbHelper = dbHelper,
        _personagemRepository = personagemRepository,
        _inimigoRepository = inimigoRepository,
        // Define o tipo uma vez no construtor para reutilização.
        _tipo = (T == Personagem) ? 'personagem' : 'inimigo';

  @override
  Future<void> save(Grupo<T> grupo) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      try {
        final grupoModel = GrupoModel(
          id: grupo.id,
          nome: grupo.nome,
          membros: grupo.membros,
        );
        await txn.insert('grupos', grupoModel.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);

        await txn.delete('grupo_membros',
            where: 'grupoId = ?', whereArgs: [grupo.id]);

        for (final membro in grupo.membros) {
          await txn.insert('grupo_membros',
              {'grupoId': grupo.id, 'combatenteId': membro.id});
        }
      } catch (e) {
        throw DatasourceException(
            message: 'Falha ao salvar o grupo.', originalException: e);
      }
    });
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('grupos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao deletar o grupo.', originalException: e);
    }
  }

  @override
  Future<Grupo<T>?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('grupos', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      return null;
    }

    final grupoMap = maps.first;
    final membros = await _getMembrosDoGrupo(db, id);

    return GrupoModel.fromMap(grupoMap, membros as List<T>);
  }

  @override
  Future<List<Grupo<T>>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('grupos', where: 'tipo = ?', whereArgs: [_tipo]);

    final List<Grupo<T>> grupos = [];
    for (final map in maps) {
      final grupo = await getById(map['id']);
      if (grupo != null) {
        grupos.add(grupo);
      }
    }
    return grupos;
  }

  // Método auxiliar para buscar os membros específicos do tipo T.
  Future<List<T>> _getMembrosDoGrupo(Database db, String grupoId) async {
    final List<Map<String, dynamic>> maps = await db
        .query('grupo_membros', where: 'grupoId = ?', whereArgs: [grupoId]);
    final List<String> ids = maps.map((map) => map['combatenteId'] as String).toList();

    final List<T> membros = [];
    for (final id in ids) {
      Combatente? membro;
      if (T == Personagem) {
        membro = await _personagemRepository.getById(id);
      } else if (T == Inimigo) {
        membro = await _inimigoRepository.getById(id);
      }

      if (membro != null) {
        membros.add(membro as T);
      }
    }
    return membros;
  }
}