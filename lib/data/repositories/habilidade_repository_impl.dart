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
      
      // REATORADO: A lógica de conversão agora está aqui.
      // O repositório identifica o tipo da entidade e cria o Map correto.
      Map<String, dynamic> persistenceMap;

      if (habilidade is HabilidadeDeDano) {
        // Se for uma habilidade de dano, cria o mapa com seus campos específicos.
        persistenceMap = {
          'id': habilidade.id,
          'nome': habilidade.nome,
          'descricao': habilidade.descricao,
          'custo': habilidade.custo,
          'nivelExigido': habilidade.nivelExigido,
          'categoria': 'dano', // <-- O "discriminador"
          'danoBase': habilidade.danoBase,
          'curaBase': null, // Garante que o campo não usado seja nulo
        };
      } else if (habilidade is HabilidadeDeCura) {
        // Se for uma habilidade de cura, cria o mapa com seus campos.
        persistenceMap = {
          'id': habilidade.id,
          'nome': habilidade.nome,
          'descricao': habilidade.descricao,
          'custo': habilidade.custo,
          'nivelExigido': habilidade.nivelExigido,
          'categoria': 'cura', // <-- O "discriminador"
          'danoBase': null,
          'curaBase': habilidade.curaBase,
        };
      } else {
        // Lança um erro se receber um tipo de Habilidade desconhecido.
        throw ArgumentError('Tipo de Habilidade não suportado para persistência: ${habilidade.runtimeType}');
      }

      await db.insert('habilidades', persistenceMap,
          conflictAlgorithm: ConflictAlgorithm.replace);

    } catch (e) {
      // O erro do ArgumentError acima também será capturado e encapsulado aqui.
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
