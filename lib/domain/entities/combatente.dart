import 'package:trabalho_rpg/domain/entities/alvo_de_acao.dart';
import 'package:trabalho_rpg/domain/entities/atributos_base.dart';
import 'package:trabalho_rpg/domain/entities/habilidade.dart';
import 'package:trabalho_rpg/domain/entities/arma.dart';
import 'package:trabalho_rpg/domain/entities/armadura.dart';

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
  Armadura? armadura;

  Combatente({
    required this.id,
    required this.nome,
    required this.nivel,
    required this.vidaMax,
    required this.classeArmadura,
    required this.atributosBase,
    required this.habilidadesPreparadas,
    this.arma,
    this.armadura,
  }) {
    vidaAtual = vidaMax;
  }

  @override
  void receberDano(int quantidade) {
    print('>> $nome (HP: $vidaAtual) recebe $quantidade de dano.');
    vidaAtual -= quantidade;
    if (vidaAtual < 0) {
      vidaAtual = 0;
    }
    print('>> Vida atual de $nome: $vidaAtual');
  }

  @override
  void receberCura(int quantidade) {
    print('>> $nome (HP: $vidaAtual) recebe $quantidade de cura.');
    vidaAtual += quantidade;
    if (vidaAtual > vidaMax) {
      vidaAtual = vidaMax;
    }
    print('>> Vida atual de $nome: $vidaAtual');
  }

  int calcularDanoContra(Combatente alvo) {
  // Define o modificador de força do atacante (padrão D&D: (atributo - 10) ~/ 2)
  final int modificadorForca = ((atributosBase.forca - 5) / 2).floor();

  // Dano base da arma + modificador de força
  int danoBruto = 10;
  if (arma != null) {
    danoBruto += arma!.danoBase + modificadorForca;
  } else {
    danoBruto += modificadorForca > 0 ? modificadorForca : 1; // sem arma, só o soco mesmo
  }

  // Defesa do alvo = armadura física + classe de armadura (CA)
  int reducaoArmadura = alvo.armadura?.danoReduzido ?? 0;
  int defesaTotal = ((reducaoArmadura + alvo.classeArmadura) * 0.5).round();

  // Cálculo do dano final
  int danoFinal = danoBruto - defesaTotal;
  if (danoFinal < 1) danoFinal = 1;

  print(
    '>> $nome causaria $danoBruto dano em ${alvo.nome} '
    '(Arma: ${arma?.nome ?? "sem arma"}, Força: ${atributosBase.forca}, '
    'Mod: $modificadorForca, Defesa: ${alvo.classeArmadura} + ${alvo.armadura?.danoReduzido ?? "sem armadura"} = $defesaTotal)',);
  
  return danoFinal;
}

}
