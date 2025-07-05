import 'package:trabalho_rpg/domain/entities/inimigo.dart';
import 'package:trabalho_rpg/domain/entities/personagem.dart';
import 'package:trabalho_rpg/domain/factories/inimigo_params.dart';
import 'package:trabalho_rpg/domain/factories/personagem_params.dart';
import 'package:trabalho_rpg/domain/factories/ficha_factory.dart';
import 'package:trabalho_rpg/domain/repositories/i_classe_personagem_repository.dart';
import 'package:trabalho_rpg/domain/repositories/i_raca_repository.dart';
import 'package:uuid/uuid.dart';

class PersonagemFactoryImpl implements IFichaFactory {
  final IRacaRepository _racaRepository;
  final IClassePersonagemRepository _classeRepository;
  final Uuid _uuid;

  // A factory depende dos repositórios para buscar as entidades.
  PersonagemFactoryImpl({
    required IRacaRepository racaRepository,
    required IClassePersonagemRepository classeRepository,
    required Uuid uuid,
  })  : _racaRepository = racaRepository,
        _classeRepository = classeRepository,
        _uuid = uuid;

  @override
  Future<Personagem> criarPersonagem(PersonagemParams params) async {
    // 1. Busca as entidades complexas no banco de dados usando os IDs.
    final raca = await _racaRepository.getById(params.racaId);
    final classe = await _classeRepository.getById(params.classeId);

    // 2. Validação: garante que a raça e a classe foram encontradas.
    if (raca == null) {
      throw Exception('Falha ao criar personagem: Raça com ID ${params.racaId} não encontrada.');
    }
    if (classe == null) {
      throw Exception('Falha ao criar personagem: Classe com ID ${params.classeId} não encontrada.');
    }

    // 3. Lógica de Negócio: Calcula valores derivados (ex: vida, CA).
    // Esta é uma lógica simplificada, poderia ser muito mais complexa.
    final vidaMax = 10 + (params.atributos.constituicao * params.nivel);
    final classeArmadura = 10 + params.atributos.destreza;

    // 4. Cria e retorna a instância final de Personagem.
    return Personagem(
      id: _uuid.v4(),
      nome: params.nome,
      nivel: params.nivel,
      raca: raca,
      classe: classe,
      atributosBase: params.atributos,
      vidaMax: vidaMax,
      classeArmadura: classeArmadura,
      // Inicializa os outros campos com valores padrão.
      habilidadesConhecidas: [],
      habilidadesPreparadas: [],
      equipamentos: {},
      arma: null,
      armadura: null,
    );
  }

  @override
  Future<Inimigo> criarInimigo(InimigoParams params) {
    // TODO: implement criarInimigo
    throw UnimplementedError();
  }
}