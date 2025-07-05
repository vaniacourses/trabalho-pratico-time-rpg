import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:uuid/uuid.dart';

class InimigoFactoryImpl implements IFichaFactory {
  final IArmaRepository _armaRepository;
  final IHabilidadeRepository _habilidadeRepository;
  final Uuid _uuid;

  InimigoFactoryImpl({
    required IArmaRepository armaRepository,
    required IHabilidadeRepository habilidadeRepository,
    required Uuid uuid,
  })  : _armaRepository = armaRepository,
        _habilidadeRepository = habilidadeRepository,
        _uuid = uuid;

  @override
  Future<Inimigo> criarInimigo(InimigoParams params) async {
    Arma? arma;
    if (params.armaId != null) {
      arma = await _armaRepository.getById(params.armaId!);
    }
    Arma? armadura;
    if (params.armaduraId != null) {
      armadura = await _armaRepository.getById(params.armaduraId!);
    }

    List<Habilidade> habilidades = [];
    for (String id in params.habilidadesIds) {
      final habilidade = await _habilidadeRepository.getById(id);
      if (habilidade != null) {
        habilidades.add(habilidade);
      }
    }
    
    final vidaMax = 5 + (params.atributos.constituicao * params.nivel);
    final classeArmadura = 10 + params.atributos.destreza;

    return Inimigo(
      id: _uuid.v4(),
      nome: params.nome,
      nivel: params.nivel,
      tipo: params.tipo,
      atributosBase: params.atributos,
      vidaMax: vidaMax,
      classeArmadura: classeArmadura,
      arma: arma,
      armadura: armadura,
      habilidadesPreparadas: habilidades,
    );
  }

  // CORREÇÃO: Adicionada a assinatura correta do método que não é implementado aqui.
  @override
  Future<Personagem> criarPersonagem(PersonagemParams params, {String? id}) {
    throw UnimplementedError('Esta factory só cria inimigos. Use PersonagemFactoryImpl para personagens.');
  }
}