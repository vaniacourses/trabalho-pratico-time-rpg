import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart'; // Import Armadura
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_armadura_repository.dart'; // Import IArmaduraRepository
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';
import 'package:uuid/uuid.dart';

class PersonagemFactoryImpl implements IFichaFactory {
  final IRacaRepository _racaRepository;
  final IClassePersonagemRepository _classeRepository;
  final IArmaRepository _armaRepository;
  final IArmaduraRepository _armaduraRepository; // Declare ArmaduraRepository
  final IHabilidadeRepository _habilidadeRepository;
  final Uuid _uuid;

  // CONSTRUCTOR: Ensure all parameters are named and explicitly typed as 'required'
  PersonagemFactoryImpl({
    required IRacaRepository racaRepository,
    required IClassePersonagemRepository classeRepository,
    required IArmaRepository armaRepository,
    required IArmaduraRepository armaduraRepository, // Added to constructor
    required IHabilidadeRepository habilidadeRepository,
    required Uuid uuid,
  })  : _racaRepository = racaRepository,
        _classeRepository = classeRepository,
        _armaRepository = armaRepository,
        _armaduraRepository = armaduraRepository, // Assign it
        _habilidadeRepository = habilidadeRepository,
        _uuid = uuid;

  @override
  Future<Personagem> criarPersonagem(
    PersonagemParams params, {
    String? id,
  }) async {
    final raca = await _racaRepository.getById(params.racaId);
    final classe = await _classeRepository.getById(params.classeId);

    if (raca == null) {
      throw Exception('Raça com ID ${params.racaId} não encontrada.');
    }
    if (classe == null) {
      throw Exception('Classe com ID ${params.classeId} não encontrada.');
    }

    Arma? arma;
    if (params.armaId != null) {
      arma = await _armaRepository.getById(params.armaId!);
    }
    Armadura? armadura;
    if (params.armaduraId != null) {
      armadura = await _armaduraRepository.getArmaduraById(params.armaduraId!); // Corrected repo call
    }

    List<Habilidade> habilidadesConhecidas = [];
    for (final habId in params.habilidadesConhecidasIds) { // These come from _habilidadesSelecionadasIds
      final hab = await _habilidadeRepository.getById(habId);
      if (hab != null) habilidadesConhecidas.add(hab);
    }

    List<Habilidade> habilidadesPreparadas = [];
    for (final habId in params.habilidadesPreparadasIds) { // These also come from _habilidadesSelecionadasIds
      final hab = await _habilidadeRepository.getById(habId);
      if (hab != null) habilidadesPreparadas.add(hab);
    }

    final vidaMax = 10 + (params.atributos.constituicao * params.nivel);
    final classeArmadura = 10 + params.atributos.destreza;

    return Personagem(
      id: id ?? _uuid.v4(),
      nome: params.nome,
      nivel: params.nivel,
      raca: raca,
      classe: classe,
      atributosBase: params.atributos,
      vidaMax: vidaMax,
      classeArmadura: classeArmadura,
      arma: arma,
      armadura: armadura,
      habilidadesConhecidas: habilidadesConhecidas,
      habilidadesPreparadas: habilidadesPreparadas,
      equipamentos: {},
    );
  }

  @override
  Future<Inimigo> criarInimigo(InimigoParams params) {
    throw UnimplementedError(
      'Esta factory só cria personagens. Use InimigoFactoryImpl.',
    );
  }
}