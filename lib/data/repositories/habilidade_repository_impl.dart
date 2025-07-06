import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/data/exceptions/datasource_exception.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_cura_model.dart';
import 'package:trabalho_rpg/data/models/habilidades/habilidade_de_dano_model.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/habilidade_de_cura.dart';
import 'package:trabalho_rpg/domain/entities/habilidade_de_dano.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';

class HabilidadeRepositoryImpl implements IHabilidadeRepository {
  final DatabaseHelper _dbHelper;

  HabilidadeRepositoryImpl({required DatabaseHelper dbHelper})
      : _dbHelper = dbHelper;

  @override
  Future<void> save(Habilidade habilidade) async {
    try {
      final db = await _dbHelper.database;

      Map<String, dynamic> persistenceMap;

      if (habilidade is HabilidadeDeDano) {
        persistenceMap = {
          'id': habilidade.id,
          'nome': habilidade.nome,
          'descricao': habilidade.descricao,
          'custo': habilidade.custo,
          'nivelExigido': habilidade.nivelExigido,
          'categoria': 'dano',
          'danoBase': habilidade.danoBase,
          'curaBase': null,
        };
      } else if (habilidade is HabilidadeDeCura) {
        persistenceMap = {
          'id': habilidade.id,
          'nome': habilidade.nome,
          'descricao': habilidade.descricao,
          'custo': habilidade.custo,
          'nivelExigido': habilidade.nivelExigido,
          'categoria': 'cura',
          'danoBase': null,
          'curaBase': habilidade.curaBase,
        };
      } else {
        throw ArgumentError('Tipo de Habilidade não suportado para persistência: ${habilidade.runtimeType}');
      }

      await db.insert('habilidades', persistenceMap,
          conflictAlgorithm: ConflictAlgorithm.replace);

    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao salvar a habilidade.', originalException: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('habilidades', where: 'id = ?', whereArgs: [id]);
      // Also delete references in combatente_habilidades
      await db.delete('combatente_habilidades', where: 'habilidadeId = ?', whereArgs: [id]);
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
            id: map['id'] as String, // Cast to String
            nome: map['nome'] as String,
            descricao: map['descricao'] as String,
            custo: map['custo'] as int,
            nivelExigido: map['nivelExigido'] as int,
            danoBase: map['danoBase'] as int? ?? 0); // Handle null for safety
      case 'cura':
        return HabilidadeDeCuraModel(
            id: map['id'] as String, // Cast to String
            nome: map['nome'] as String,
            descricao: map['descricao'] as String,
            custo: map['custo'] as int,
            nivelExigido: map['nivelExigido'] as int,
            curaBase: map['curaBase'] as int? ?? 0); // Handle null for safety
      default:
        // Fallback for generic Habilidade or throw error for unknown type
        // Ensure default constructor matches if no category.
        throw Exception('Categoria de habilidade desconhecida no banco de dados: $categoria');
        // throw Exception('Categoria de habilidade desconhecida no banco de dados: $categoria');
    }
  }

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

      final List<Habilidade> known = []; // Use 'known'
      final List<Habilidade> prepared = []; // Use 'prepared'

      for (final map in maps) {
        final habilidade = _mapToHabilidade(map);
        final type = map['tipo'] as String?; // Get the type from the join table, allow null

        if (type == 'known') { // Check against 'known'
          known.add(habilidade);
        } else if (type == 'prepared') { // Check against 'prepared'
          prepared.add(habilidade);
        }
      }
      return {'known': known, 'prepared': prepared}; // Return with 'known' and 'prepared' keys
    } catch (e) {
      throw DatasourceException(
          message: 'Falha ao buscar habilidades para o combatente.', originalException: e);
    }
  }
}
