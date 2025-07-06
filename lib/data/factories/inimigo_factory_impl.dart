// Assuming the necessary imports are already present in your file
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart'; // NEW: Add Armadura import
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_armadura_repository.dart'; // NEW: Add IArmaduraRepository import
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:uuid/uuid.dart';

class InimigoFactoryImpl implements IFichaFactory {
  final IArmaRepository _armaRepository;
  final IArmaduraRepository _armaduraRepository; // NEW: Declare ArmaduraRepository
  final IHabilidadeRepository _habilidadeRepository;
  final Uuid _uuid;

  // CONSTRUCTOR: Ensure all parameters are named and explicitly typed as 'required'
  InimigoFactoryImpl({
    required IArmaRepository armaRepository,
    required IArmaduraRepository armaduraRepository, // NEW: Add to constructor
    required IHabilidadeRepository habilidadeRepository,
    required Uuid uuid,
  })  : _armaRepository = armaRepository,
        _armaduraRepository = armaduraRepository, // Assign it
        _habilidadeRepository = habilidadeRepository,
        _uuid = uuid;

  @override
  Future<Inimigo> criarInimigo(InimigoParams params) async {
    // 1. Busca as dependências opcionais (arma, armadura, habilidades).
    Arma? arma;
    if (params.armaId != null) {
      arma = await _armaRepository.getById(params.armaId!);
    }
    Armadura? armadura;
    if (params.armaduraId != null) {
      armadura = await _armaduraRepository.getArmaduraById(params.armaduraId!); // CORRECTED: Use _armaduraRepository
    }

    List<Habilidade> habilidades = [];
    if (params.habilidadesIds != null) {
      for (final habId in params.habilidadesIds!) {
        final hab = await _habilidadeRepository.getById(habId);
        if (hab != null) habilidades.add(hab);
      }
    }

    // 2. Lógica de Negócio para calcular valores derivados (ex: vidaMax, classeArmadura).
    final vidaMax = 50 + (params.atributos.constituicao * params.nivel); // Example calculation
    final classeArmadura = 10 + params.atributos.destreza; // Example calculation

    // 3. Cria e retorna a instância final de Inimigo.
    return Inimigo(
      id: params.id ?? _uuid.v4(),
      nome: params.nome,
      nivel: params.nivel,
      tipo: params.tipo,
      atributosBase: params.atributos,
      vidaMax: vidaMax,
      classeArmadura: classeArmadura,
      arma: arma,
      armadura: armadura, // Now correctly passed as Armadura?
      habilidadesPreparadas: habilidades,
    );
  }

  @override
  Future<Personagem> criarPersonagem(PersonagemParams params, {String? id}) {
    throw UnimplementedError(
      'Esta factory só cria inimigos. Use PersonagemFactoryImpl.',
    );
  }
}