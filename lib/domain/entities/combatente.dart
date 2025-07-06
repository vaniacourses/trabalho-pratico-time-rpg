import 'package:trabalho_rpg/domain/entities/alvo_de_acao.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart'; // ADICIONADO: Import da classe Armadura

abstract class Combatente implements AlvoDeAcao {
  final String id;
  String nome;
  int nivel;
  int vidaMax;
  late int vidaAtual;
  int classeArmadura;
  AtributosBase atributosBase;
  List<Habilidade> habilidadesPreparadas;

  Arma? arma;
  Armadura? armadura; // <<<<<<<<<<<<<<< C O R R E T E D   T Y P E

  Combatente({
    required this.id,
    required this.nome,
    required this.nivel,
    required this.vidaMax,
    required this.classeArmadura,
    required this.atributosBase,
    required this.habilidadesPreparadas,
    this.arma,
    this.armadura, // <<<<<<<<<<<<<<< C O R R E C T E D   T Y P E
  }) {
    vidaAtual = vidaMax;
  }

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