import 'package:trabalho_rpg/domain/entities/alvo_de_acao.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
// ADICIONADO: Import da classe Arma
import 'package:trabalho_rpg/domain/entities/arma.dart';

// ATUALIZAÇÃO: Agora implementa a interface AlvoDeAcao
abstract class Combatente implements AlvoDeAcao {
  final String id;
  String nome;
  int nivel;
  int vidaMax;
  late int vidaAtual;
  int classeArmadura;
  AtributosBase atributosBase;
  List<Habilidade> habilidadesPreparadas;

  // ADICIONADO: Atributos movidos para a classe base.
  Arma? arma;
  Arma? armadura;
  
  Combatente({
    required this.id,
    required this.nome,
    required this.nivel,
    required this.vidaMax,
    required this.classeArmadura,
    required this.atributosBase,
    required this.habilidadesPreparadas,
    // ADICIONADO: Parâmetros no construtor da base.
    this.arma,
    this.armadura,
  }) {
    vidaAtual = vidaMax;
  }

  // ATUALIZAÇÃO: Implementação dos métodos da interface.
  @override
  void receberDano(int quantidade) {
    print('>> ${nome} (HP: $vidaAtual) recebe $quantidade de dano.');
    vidaAtual -= quantidade;
    if (vidaAtual < 0) {
      vidaAtual = 0;
    }
    print('>> Vida atual de ${nome}: $vidaAtual');
  }

  @override
  void receberCura(int quantidade) {
    print('>> ${nome} (HP: $vidaAtual) recebe $quantidade de cura.');
    vidaAtual += quantidade;
    if (vidaAtual > vidaMax) {
      vidaAtual = vidaMax;
    }
    print('>> Vida atual de ${nome}: $vidaAtual');
  }
}