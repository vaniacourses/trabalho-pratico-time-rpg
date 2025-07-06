import 'package:sqflite/sqflite.dart';
import 'package:trabalho_rpg/data/datasources/database_helper.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/classe_personagem.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/entities/raca.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_armadura_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';

class PersonagemRepositoryImpl implements IPersonagemRepository {
  final DatabaseHelper dbHelper;
  final IHabilidadeRepository habilidadeRepository;
  final IRacaRepository racaRepository;
  final IClassePersonagemRepository classeRepository;
  final IArmaRepository armaRepository;
  final IArmaduraRepository armaduraRepository;

  PersonagemRepositoryImpl({
    required this.dbHelper,
    required this.habilidadeRepository,
    required this.racaRepository,
    required this.classeRepository,
    required this.armaRepository,
    required this.armaduraRepository,
  });

  @override
  Future<List<Personagem>> getAll() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('personagens');
    final List<Personagem> personagens = [];

    for (var map in maps) {
      // Ensure IDs are correctly cast to String
      final String? racaId = map['racaId'] as String?;
      final String? classeId = map['classeId'] as String?;
      final String? armaId = map['armaId'] as String?;
      final String? armaduraId = map['armaduraId'] as String?;
      final String id = map['id'] as String;

      // Fetch required entities (Raca, Classe)
      final Raca? raca = racaId != null ? await racaRepository.getById(racaId) : null;
      final ClassePersonagem? classe = classeId != null ? await classeRepository.getById(classeId) : null;

      if (raca == null) {
        // Log a warning or handle as needed, but this character might be invalid
        print('Skipping character ${map['nome']} (ID: $id) due to missing Race (ID: $racaId).');
        continue; // Skip this character if its required Raca is missing
      }
      if (classe == null) {
        print('Skipping character ${map['nome']} (ID: $id) due to missing Class (ID: $classeId).');
        continue; // Skip this character if its required Classe is missing
      }

      // Fetch optional entities (Arma, Armadura)
      Arma? arma;
      if (armaId != null) {
        arma = await armaRepository.getById(armaId);
        if (arma == null) {
          print('Warning: Character ${map['nome']} (ID: $id) has missing Weapon (ID: $armaId).');
        }
      }

      Armadura? armadura;
      if (armaduraId != null) {
        armadura = await armaduraRepository.getArmaduraById(armaduraId);
        if (armadura == null) {
          print('Warning: Character ${map['nome']} (ID: $id) has missing Armor (ID: $armaduraId).');
        }
      }

      final habilidadesData = await habilidadeRepository.getAllForCombatente(id);
      final List<Habilidade> habilidadesConhecidas = habilidadesData['known'] ?? [];
      final List<Habilidade> habilidadesPreparadas = habilidadesData['prepared'] ?? [];

      personagens.add(Personagem(
        id: id,
        nome: map['nome'] as String,
        nivel: map['nivel'] as int,
        vidaMax: map['vidaMax'] as int,
        classeArmadura: map['classeArmadura'] as int,
        raca: raca, // Raca is guaranteed non-null here
        classe: classe, // Classe is guaranteed non-null here
        atributosBase: AtributosBase(
          forca: map['forca'] as int,
          destreza: map['destreza'] as int,
          constituicao: map['constituicao'] as int,
          inteligencia: map['inteligencia'] as int,
          sabedoria: map['sabedoria'] as int,
          carisma: map['carisma'] as int,
        ),
        arma: arma, // Can be null
        armadura: armadura, // Can be null
        habilidadesConhecidas: habilidadesConhecidas,
        habilidadesPreparadas: habilidadesPreparadas,
        equipamentos: {}, // Assuming this remains an empty map unless populated elsewhere
      ));
    }
    return personagens;
  }

  @override
  Future<Personagem?> getById(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'personagens',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      final String? racaId = map['racaId'] as String?;
      final String? classeId = map['classeId'] as String?;
      final String? armaId = map['armaId'] as String?;
      final String? armaduraId = map['armaduraId'] as String?;

      final Raca? raca = racaId != null ? await racaRepository.getById(racaId) : null;
      final ClassePersonagem? classe = classeId != null ? await classeRepository.getById(classeId) : null;

      if (raca == null) {
        print('Character ${map['nome']} (ID: $id) has missing Race (ID: $racaId). Cannot fully retrieve.');
        return null;
      }
      if (classe == null) {
        print('Character ${map['nome']} (ID: $id) has missing Class (ID: $classeId). Cannot fully retrieve.');
        return null;
      }

      Arma? arma;
      if (armaId != null) {
        arma = await armaRepository.getById(armaId);
      }

      Armadura? armadura;
      if (armaduraId != null) {
        armadura = await armaduraRepository.getArmaduraById(armaduraId);
      }

      final habilidadesData = await habilidadeRepository.getAllForCombatente(map['id'] as String);
      final List<Habilidade> habilidadesConhecidas = habilidadesData['known'] ?? [];
      final List<Habilidade> habilidadesPreparadas = habilidadesData['prepared'] ?? [];

      return Personagem(
        id: map['id'] as String,
        nome: map['nome'] as String,
        nivel: map['nivel'] as int,
        vidaMax: map['vidaMax'] as int,
        classeArmadura: map['classeArmadura'] as int,
        raca: raca,
        classe: classe,
        atributosBase: AtributosBase(
          forca: map['forca'] as int,
          destreza: map['destreza'] as int,
          constituicao: map['constituicao'] as int,
          inteligencia: map['inteligencia'] as int,
          sabedoria: map['sabedoria'] as int,
          carisma: map['carisma'] as int,
        ),
        arma: arma,
        armadura: armadura,
        habilidadesConhecidas: habilidadesConhecidas,
        habilidadesPreparadas: habilidadesPreparadas,
        equipamentos: {},
      );
    }
    return null;
  }

  @override
  Future<void> save(Personagem personagem) async {
    final db = await dbHelper.database;
    // Save abilities and equipment links before saving the main character
    await _saveCombatenteHabilidades(db, personagem.id, personagem.habilidadesConhecidas, 'known');
    await _saveCombatenteHabilidades(db, personagem.id, personagem.habilidadesPreparadas, 'prepared');
    await _saveCombatenteEquipamentos(db, personagem.id, personagem.arma, personagem.armadura);

    await db.insert(
      'personagens',
      {
        'id': personagem.id,
        'nome': personagem.nome,
        'nivel': personagem.nivel,
        'vidaMax': personagem.vidaMax,
        'classeArmadura': personagem.classeArmadura,
        'racaId': personagem.raca.id,
        'classeId': personagem.classe.id,
        'forca': personagem.atributosBase.forca,
        'destreza': personagem.atributosBase.destreza,
        'constituicao': personagem.atributosBase.constituicao,
        'inteligencia': personagem.atributosBase.inteligencia,
        'sabedoria': personagem.atributosBase.sabedoria,
        'carisma': personagem.atributosBase.carisma,
        'armaId': personagem.arma?.id,
        'armaduraId': personagem.armadura?.id,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _saveCombatenteHabilidades(
      Database db, String combatenteId, List<Habilidade> habilidades, String type) async {
    await db.delete(
      'combatente_habilidades',
      where: 'combatenteId = ? AND tipo = ?',
      whereArgs: [combatenteId, type],
    );
    for (var h in habilidades) {
      await db.insert(
        'combatente_habilidades',
        {
          'combatenteId': combatenteId,
          'habilidadeId': h.id,
          'tipo': type,
        },
      );
    }
  }

  Future<void> _saveCombatenteEquipamentos(
      Database db, String combatenteId, Arma? arma, Armadura? armadura) async {
    await db.delete(
      'combatente_equipamentos',
      where: 'combatenteId = ?',
      whereArgs: [combatenteId],
    );

    if (arma != null) {
      await db.insert(
        'combatente_equipamentos',
        {'combatenteId': combatenteId, 'itemId': arma.id, 'slot': 'arma'},
      );
    }
    if (armadura != null) {
      await db.insert(
        'combatente_equipamentos',
        {'combatenteId': combatenteId, 'itemId': armadura.id, 'slot': 'armadura'},
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'personagens',
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.delete('combatente_habilidades', where: 'combatenteId = ?', whereArgs: [id]);
    await db.delete('combatente_equipamentos', where: 'combatenteId = ?', whereArgs: [id]);
  }
}