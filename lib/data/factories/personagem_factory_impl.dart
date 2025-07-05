import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';
import 'package:uuid/uuid.dart';

class PersonagemFactoryImpl implements IFichaFactory {
  final IRacaRepository _racaRepository;
  final IClassePersonagemRepository _classeRepository;
  // CORREÇÃO: Adicionando os repositórios que faltavam
  final IArmaRepository _armaRepository;
  final IHabilidadeRepository _habilidadeRepository;
  final Uuid _uuid;

  // CORREÇÃO: Construtor atualizado para receber todas as dependências.
  PersonagemFactoryImpl({
    required IRacaRepository racaRepository,
    required IClassePersonagemRepository classeRepository,
    required IArmaRepository armaRepository,
    required IHabilidadeRepository habilidadeRepository,
    required Uuid uuid,
  })  : _racaRepository = racaRepository,
        _classeRepository = classeRepository,
       _armaRepository = armaRepository,
       _habilidadeRepository = habilidadeRepository,
        _uuid = uuid;

  @override
  Future<Personagem> criarPersonagem(
    PersonagemParams params, {
    String? id,
  }) async {
    // 1. Busca as entidades complexas obrigatórias.
    final raca = await _racaRepository.getById(params.racaId);
    final classe = await _classeRepository.getById(params.classeId);

    if (raca == null)
      throw Exception('Raça com ID ${params.racaId} não encontrada.');
    if (classe == null)
      throw Exception('Classe com ID ${params.classeId} não encontrada.');

    // 2. Busca as dependências opcionais (armas, habilidades).
    Arma? arma;
    if (params.armaId != null) {
      arma = await _armaRepository.getById(params.armaId!);
    }
    Arma? armadura;
    if (params.armaduraId != null) {
      armadura = await _armaRepository.getById(params.armaduraId!);
    }

    List<Habilidade> habilidadesConhecidas = [];
    for (final habId in params.habilidadesConhecidasIds) {
      final hab = await _habilidadeRepository.getById(habId);
      if (hab != null) habilidadesConhecidas.add(hab);
    }
    
    // Simplificação: no futuro, a lista de preparadas seria um subconjunto das conhecidas.
    List<Habilidade> habilidadesPreparadas = [];
    for (final habId in params.habilidadesPreparadasIds) {
      final hab = await _habilidadeRepository.getById(habId);
      if (hab != null) habilidadesPreparadas.add(hab);
    }

    // 3. Lógica de Negócio para calcular valores derivados.
    final vidaMax = 10 + (params.atributos.constituicao * params.nivel);
    final classeArmadura = 10 + params.atributos.destreza;

    // 4. Cria e retorna a instância final de Personagem.
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
      equipamentos: {}, // Lógica de equipamentos pode ser adicionada aqui
    );
  }

  @override
  Future<Inimigo> criarInimigo(InimigoParams params) {
    throw UnimplementedError(
      'Esta factory só cria personagens. Use InimigoFactoryImpl.',
    );
  }
}