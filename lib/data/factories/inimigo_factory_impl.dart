import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/repositories/i_arma_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_habilidade_repository.dart';
import 'package:uuid/uuid.dart';

// Nota: Esta classe implementa apenas a parte de Inimigo da interface.
// Em uma aplicação maior, poderíamos ter uma única classe Factory que implementa
// ambos os métodos, ou manter separado como aqui para responsabilidades distintas.
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
    // 1. Busca as dependências opcionais
    Arma? arma;
    if (params.armaId != null) {
      arma = await _armaRepository.getById(params.armaId!);
    }
    Arma? armadura;
    if (params.armaduraId != null) {
      armadura = await _armaRepository.getById(params.armaduraId!);
    }

    // 2. Busca a lista de habilidades
    List<Habilidade> habilidades = [];
    for (String id in params.habilidadesIds) {
      final habilidade = await _habilidadeRepository.getById(id);
      if (habilidade != null) {
        habilidades.add(habilidade);
      }
    }
    
    // 3. Lógica de Negócio (cálculos)
    final vidaMax = 5 + (params.atributos.constituicao * params.nivel);
    final classeArmadura = 10 + params.atributos.destreza;

    // 4. Cria e retorna a instância final do Inimigo
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

  // Este método não é implementado por esta classe.
  // Lançar um erro garante que ele não seja chamado acidentalmente.
  @override
  Future<Personagem> criarPersonagem(params) {
    throw UnimplementedError('Esta factory só cria inimigos. Use PersonagemFactoryImpl para personagens.');
  }
}