import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_cura_model.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_dano_model.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';

class HabilidadeRepositoryImpl implements IHabilidadeRepository {
  final DatabaseHelper _dbHelper;

  HabilidadeRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<void> save(Habilidade habilidade) async {
    try {
      final db = await _dbHelper.database;
      
      // ATUALIZAÇÃO: A lógica agora é muito mais simples!
      // A própria habilidade sabe como ser convertida para o banco.
      // Não precisamos mais de 'if/is'.
      await db.insert('habilidades', habilidade.toPersistenceMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);

    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao salvar a habilidade.', originalException: e);
    }
  }

  // O restante do arquivo (delete, getById, getAll, _mapToHabilidade)
  // permanece exatamente o mesmo da versão anterior e correta.
  @override
  Future<void> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('habilidades', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao deletar a habilidade.', originalException: e);
    }
  }

  @override
  Future<Habilidade?> getById(String id) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'habilidades',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _mapToHabilidade(maps.first);
      }
      return null;
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao buscar habilidade por ID.', originalException: e);
    }
  }

  @override
  Future<List<Habilidade>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('habilidades');
      return maps.map((map) => _mapToHabilidade(map)).toList();
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao buscar todas as habilidades.',
          originalException: e);
    }
  }

  Habilidade _mapToHabilidade(Map<String, dynamic> map) {
    final categoria = map['categoria'] as String?;
    switch (categoria) {
      case 'dano':
        return HabilidadeDeDanoModel(
            id: map['id'], nome: map['nome'], descricao: map['descricao'],
            custo: map['custo'], nivelExigido: map['nivelExigido'],
            danoBase: map['danoBase'] ?? 0);
      case 'cura':
        return HabilidadeDeCuraModel(
            id: map['id'], nome: map['nome'], descricao: map['descricao'],
            custo: map['custo'], nivelExigido: map['nivelExigido'],
            curaBase: map['curaBase'] ?? 0);
      default:
        throw Exception('Categoria de habilidade desconhecida no banco de dados: $categoria');
    }
  }

  // ATUALIZAÇÃO: Implementação do novo método.
  @override
  Future<Map<String, List<Habilidade>>> getAllForCombatente(String combatenteId) async {
    try {
      final db = await _dbHelper.database;
      const String sql = '''
        SELECT h.*, ch.tipo FROM habilidades h
        JOIN combatente_habilidades ch ON h.id = ch.habilidadeId
        WHERE ch.combatenteId = ?
      ''';
      final maps = await db.rawQuery(sql, [combatenteId]);
      
      final List<Habilidade> conhecidas = [];
      final List<Habilidade> preparadas = [];
      
      for (final map in maps) {
        final habilidade = _mapToHabilidade(map);
        conhecidas.add(habilidade);
        if (map['tipo'] == 'preparada') {
          preparadas.add(habilidade);
        }
      }
      return {'conhecidas': conhecidas, 'preparadas': preparadas};
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao buscar habilidades para o combatente.', originalException: e);
    }
  }
}
